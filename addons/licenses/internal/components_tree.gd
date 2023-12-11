@tool
extends Tree

const Component := preload("../component.gd")
const ComponentsContainer := preload("components_container.gd")
const Licenses := preload("../licenses.gd")

const _BTN_ID_REMOVE: int = 2

signal component_selected(comp: Component)
signal component_remove(comp: Component)
signal component_add(comp: Component)

var show_readonly_components: bool = false:
    set = set_show_readonly_components
var _components: ComponentsContainer
## cached value
var _readonly_components: Array[Component] = []

func set_show_readonly_components(show: bool) -> void:
    show_readonly_components = show
    if show:
        self._readonly_components = Licenses.get_required_engine_components()
    else:
        self._readonly_components = []
    self.reload()

func _ready() -> void:
    self.allow_rmb_select = true

# only used once
func set_components(comp: ComponentsContainer) -> void:
    self._components = comp

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
        item.add_button(0, self.get_theme_icon("Remove", "EditorIcons"), _BTN_ID_REMOVE)
    var tooltip = component.name
    var comp_warnings: PackedStringArray = component.get_warnings()
    if comp_warnings.size() != 0:
        tooltip += "\n- " + "\n- ".join(comp_warnings)
        item.set_icon(0, self.get_theme_icon("NodeWarning", "EditorIcons"))
    item.set_tooltip_text(0, tooltip)
    return item

func reload(scroll_to: Component = null) -> void:
    self.clear()
    if self.get_root() != null:
        push_error("could not clear")

    var category_cache: Dictionary = {}
    var root: TreeItem = self.create_item(null)
    category_cache[""] = root
    # count current added engine component
    var readonly_idx: int = 0
    # count current added custom components
    var idx: int = 0

    while idx < self._components.count() or readonly_idx < len(self._readonly_components):
        var component: Component = null
        var cur_idx: int = 0
        var cmp: bool = false
        # compare readonly items with editable, to determine which one to show first
        if idx < self._components.count() and readonly_idx < len(self._readonly_components):
            cmp = Licenses.compare_components_ascending(self._components.get_at(idx), self._readonly_components[readonly_idx])
        if readonly_idx >= len(self._readonly_components) or cmp:
            component = self._components.get_at(idx)
            cur_idx = idx
            idx = idx + 1
        elif idx >= self._components.count() or not cmp:
            component = self._readonly_components[readonly_idx]
            cur_idx = readonly_idx
            readonly_idx = readonly_idx + 1

        var parent: TreeItem = self._create_category_item(category_cache, component.category, root)
        var item: TreeItem = self._add_tree_item(component, cur_idx, parent)
        if scroll_to != null && component == scroll_to:
            self.scroll_to_item(item)
            item.select(0)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
    var item: TreeItem = self.get_item_at_position(at_position)
    return item != null and data is TreeItem

func _get_drag_data(at_position: Vector2) -> Variant:
    var item: TreeItem = self.get_item_at_position(at_position)
    if item == null:
        return null
    if not item.has_meta("idx") or (item.get_meta("readonly") as bool):
        return null

    self.set_drop_mode_flags(Tree.DROP_MODE_INBETWEEN)

    var preview: Label = Label.new()
    preview.text = item.get_text(0)
    self.set_drag_preview(preview)

    return item

func _drop_data(at_position: Vector2, data: Variant) -> void:
    var to_item: TreeItem = self.get_item_at_position(at_position)
    var shift: int = self.get_drop_section_at_position(at_position)
    # above category node
    var category: String = ""
    # below or above item with category
    if to_item.has_meta("idx"):
        category = self._components.get_at(to_item.get_meta("idx") as int).category
    # below category node
    elif shift == 1:
        category = to_item.get_text(0)
    var cur_component: Component = self._components.get_at(data.get_meta("idx") as int)
    if cur_component.category == category:
        return
    cur_component.category = category
    self._components.sort_custom(Licenses.compare_components_ascending)
    self._components.emit_changed()

func _on_item_selected() -> void:
    var item: TreeItem = self.get_selected()
    if not item.has_meta("readonly"):
        return
    var component: Component
    if item.get_meta("readonly") as bool:
        component = self._readonly_components[item.get_meta("idx")]
    else:
        component = self._components.get_at(item.get_meta("idx") as int)
    self.component_selected.emit(component)

func _on_button_clicked(item: TreeItem, column: int, id: int, mouse_button_idx: int) -> void:
    match id:
        _BTN_ID_REMOVE:
            self.component_remove.emit(self._components.get_at(item.get_meta("idx") as int))

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
