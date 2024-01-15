@tool
extends Tree

const Component := preload("res://addons/licenses/component.gd")
const ComponentsContainer := preload("res://addons/licenses/internal/components_container.gd")
const Licenses := preload("res://addons/licenses/licenses.gd")

const _BTN_ID_REMOVE: int = 2

signal component_selected(comp: Component)
signal component_remove(comp: Component)
signal component_add(comp: Component)

var show_readonly_components: bool = false:
    set = set_show_readonly_components
var _components: ComponentsContainer
## cached value
var _readonly_components: Array[Component] = []
var _item_menu: PopupMenu

func set_show_readonly_components(show_: bool) -> void:
    var sel_comp: Component = self._get_selected_component()
    show_readonly_components = show_
    if show_:
        self._readonly_components = Licenses.get_required_engine_components()
        self.reload(sel_comp)
    else:
        self._readonly_components = []
        if sel_comp != null && sel_comp.readonly:
            self.reload()
            self.component_selected.emit(null)
        else:
            self.reload(sel_comp)

func set_components(comp: ComponentsContainer) -> void:
    self._components = comp
    self.reload()

func _ready() -> void:
    self._create_item_menu()
    self.gui_input.connect(self._on_gui_input)

func reload(scroll_to: Component = null) -> void:
    self.clear()

    var category_cache: Dictionary = {}
    var root: TreeItem = self.create_item(null)
    category_cache[""] = root
    # count current added engine component
    var readonly_idx: int = 0
    # count current added custom components
    var idx: int = 0

    while idx < self._components.count() || readonly_idx < len(self._readonly_components):
        var component: Component = null
        var cur_idx: int = 0
        var cmp: bool = false
        # compare readonly items with editable, to determine which one to show first
        if idx < self._components.count() && readonly_idx < len(self._readonly_components):
            cmp = Licenses.compare_components_ascending(self._components.get_at(idx), self._readonly_components[readonly_idx])
        if readonly_idx >= len(self._readonly_components) || cmp:
            component = self._components.get_at(idx)
            cur_idx = idx
            idx = idx + 1
        elif idx >= self._components.count() || not cmp:
            component = self._readonly_components[readonly_idx]
            cur_idx = readonly_idx
            readonly_idx = readonly_idx + 1

        var parent: TreeItem = self._create_category_item(category_cache, component.category, root)
        var item: TreeItem = self._add_tree_item(component, cur_idx, parent)
        if scroll_to != null && component == scroll_to:
            self.scroll_to_item(item)
            item.select(0)

func _create_item_menu() -> void:
    self._item_menu = PopupMenu.new()
    self._item_menu.name = "item_menu"
    self._item_menu.id_pressed.connect(self._on_item_menu_pressed)
    self._item_menu.add_icon_item(self.get_theme_icon(&"Duplicate", &"EditorIcons"), "Duplicate")
    self._item_menu.add_icon_item(self.get_theme_icon(&"Remove", &"EditorIcons"), "Delete")
    self._item_menu.size = self._item_menu.get_contents_minimum_size()
    self.add_child(self._item_menu)

func _create_category_item(category_cache: Dictionary, category: String, root: TreeItem) -> TreeItem:
    if category in category_cache:
        return category_cache[category]
    var category_item: TreeItem
    category_item = self.create_item(root)
    category_item.set_text(0, category)
    category_item.set_editable(0, true)
    category_item.set_meta("category", category)
    category_cache[category] = category_item
    return category_item

func _add_tree_item(component: Component, idx: int, parent: TreeItem) -> TreeItem:
    var item: TreeItem = self.create_item(parent)
    item.set_text(0, component.name)
    item.set_meta("idx", idx)
    item.set_meta("readonly", component.readonly)
    if not component.readonly:
        item.add_button(0, self.get_theme_icon(&"Remove", &"EditorIcons"), _BTN_ID_REMOVE)
    var tooltip: String = component.name
    var comp_warnings: PackedStringArray = component.get_warnings()
    if comp_warnings.size() != 0:
        tooltip += "\n- " + "\n- ".join(comp_warnings)
        item.set_icon(0, self.get_theme_icon(&"NodeWarning", &"EditorIcons"))
    item.set_tooltip_text(0, tooltip)
    return item

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
    var item: TreeItem = self.get_item_at_position(at_position)
    return item != null && data is TreeItem && item.has_meta("category")

func _get_drag_data(at_position: Vector2) -> Variant:
    var item: TreeItem = self.get_item_at_position(at_position)
    if item == null:
        return null
    if not item.has_meta("idx") || (item.get_meta("readonly") as bool):
        return null

    self.set_drop_mode_flags(Tree.DROP_MODE_ON_ITEM)
    
    # color possible category items
    var tree_item: TreeItem = self.get_root().get_next_in_tree()
    while tree_item != null:
        if tree_item.has_meta("category"):
            tree_item.set_custom_color(0, self.get_theme_color(&"accent_color", &"Editor"))
        tree_item = tree_item.get_next()

    var preview: Label = Label.new()
    preview.text = item.get_text(0)
    self.set_drag_preview(preview)

    return item

func _drop_data(at_position: Vector2, data: Variant) -> void:
    var to_item: TreeItem = self.get_item_at_position(at_position)
    var category = to_item.get_meta("category")
    var cur_component: Component = self._get_selected_component()
    if cur_component.category == category:
        return
    cur_component.category = category
    self._components.sort_custom(Licenses.compare_components_ascending)
    self._components.emit_changed()

func _notification(what: int):
    if what == NOTIFICATION_DRAG_END:
        # clear custom color from dragging
        var item: TreeItem = self.get_root().get_next_in_tree()
        while item != null:
            if item.has_meta("category"):
                item.clear_custom_color(0)
            item = item.get_next()

func _get_selected_component() -> Component:
    var item: TreeItem = self.get_selected()
    if item == null || !item.has_meta("idx"):
        return null
    var component: Component = null
    if item.get_meta("readonly") as bool:
        component = self._readonly_components[item.get_meta("idx")]
    else:
        component = self._components.get_at(item.get_meta("idx") as int)
    return component

func _on_item_selected() -> void:
    self.component_selected.emit(self._get_selected_component())

func _on_button_clicked(item: TreeItem, column: int, id: int, mouse_button_idx: int) -> void:
    match id:
        _BTN_ID_REMOVE:
            self.component_remove.emit(self._get_selected_component())

func _on_item_edited() -> void:
    var category_item: TreeItem = self.get_edited()
    var old_category: String = category_item.get_meta("category")
    var new_category: String = category_item.get_text(0)
    category_item.set_meta("category", new_category)
    for component: Component in self._components.components():
        if component.category == old_category:
            component.category = new_category

    self._components.sort_custom(Licenses.compare_components_ascending)
    self._components.emit_changed()

func _on_gui_input(event: InputEvent) -> void:
    if !((event is InputEventMouseButton) && (event as InputEventMouseButton).pressed && (event as InputEventMouseButton).button_index == MOUSE_BUTTON_RIGHT):
        return
    var item: TreeItem = self.get_item_at_position((event as InputEventMouseButton).position)
    if item == null || !item.has_meta("idx") || !item.has_meta("readonly"):
        return

    self._item_menu.set_item_disabled(1, item.get_meta("readonly") as bool)
    self._item_menu.popup_on_parent(Rect2(self.get_local_mouse_position() + Vector2(9, self._item_menu.size.y + 3), self._item_menu.size))

func _on_item_menu_pressed(btn_idx: int) -> void:
    var comp: Component = self._get_selected_component()
    match btn_idx:
        0:
            var new_comp: Component = comp.duplicate()
            new_comp.readonly = false
            new_comp.name = new_comp.name + " Copy"
            self.component_add.emit(new_comp)
        1:
            self.component_remove.emit(comp)
