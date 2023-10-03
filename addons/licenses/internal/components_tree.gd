@tool
extends Tree

const Component := preload("../component.gd")
const ComponentDetailTree := preload("component_detail_tree.gd")
const BaseHandler := preload("handler/base.gd")
const ObjectHandler := preload("handler/object.gd")
const ArrayHandler := preload("handler/array.gd")
const StringHandler := preload("handler/string.gd")
const StringFileHandler := preload("handler/string_file.gd")
const StringMultiLineHandler := preload("handler/string_multiline.gd")
const Licenses := preload("../licenses.gd")

const _BTN_ID_REMOVE: int = 2

signal components_changed()

@export_node_path("Tree") var _component_detail_path; @onready var _component_detail: ComponentDetailTree = self.get_node(_component_detail_path)

var show_readonly_components: bool = false:
    set = set_show_readonly_components
var _components: Array[Component] = []
## cached value
var _readonly_components: Array[Component] = []

func set_show_readonly_components(show: bool) -> void:
    show_readonly_components = show
    if show:
        self._readonly_components = Licenses.get_required_engine_components()
    else:
        self._readonly_components = []

func _ready() -> void:
    self._component_detail.component_edited.connect(self._on_component_edited)
    self._component_detail.handlers = [ObjectHandler, StringFileHandler, StringMultiLineHandler, StringHandler, ArrayHandler]

func add_component(component: Component) -> void:
    self._components.append(component)
    self._components.sort_custom(Licenses.compare_components_ascending)
    self.reload()

# will not emit components_changed signal
func set_components(components_: Array[Component]) -> void:
    self._components = components_
    self.reload()

func get_components() -> Array[Component]:
    return self._components

# also reloads the view
# do not use internally
func select_component(component: Component) -> void:
    self._component_detail.set_component(component)
    self.reload()

func get_selected_component() -> Component:
    return self._component_detail.get_component()

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

func _add_component(component: Component, category_cache: Dictionary, root: TreeItem, idx: int) -> TreeItem:
    var parent: TreeItem = self._create_category_item(category_cache, component.category, root)
    return self._add_tree_item(component, idx, parent)

func reload() -> void:
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

    while idx < len(self._components) or readonly_idx < len(self._readonly_components):
        var component: Component = null
        var cur_idx: int = 0
        var cmp: bool = false
        if idx < len(self._components) and readonly_idx < len(self._readonly_components):
            cmp = Licenses.compare_components_ascending(self._components[idx], self._readonly_components[readonly_idx])
        if readonly_idx >= len(self._readonly_components) or cmp:
            component = self._components[idx]
            cur_idx = idx
            idx = idx + 1
        elif idx >= len(self._components) or not cmp:
            component = self._readonly_components[readonly_idx]
            cur_idx = readonly_idx
            readonly_idx = readonly_idx + 1

        var item: TreeItem = self._add_component(component, category_cache, root, cur_idx)
        if component == self._component_detail.get_component():
            self.scroll_to_item(item)
            item.select(0)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
    var item: TreeItem = self.get_item_at_position(at_position)
    return item != null and data is TreeItem

func _get_drag_data(at_position: Vector2) -> Variant:
    var item: TreeItem = self.get_item_at_position(at_position)
    if item == null:
        return null
    if not item.has_meta("idx") or item.get_meta("readonly"):
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
        category = self._components[to_item.get_meta("idx")].category
    # below category node
    elif shift == 1:
        category = to_item.get_text(0)
    var cur_component: Component = self._components[data.get_meta("idx")]
    if cur_component.category == category:
        return
    cur_component.category = category
    self._components.sort_custom(Licenses.compare_components_ascending)
    self.components_changed.emit()
    self.reload()
    self._component_detail.reload()

func _on_item_selected() -> void:
    var item: TreeItem = self.get_selected()
    if not item.has_meta("readonly"):
        return
    var component: Component
    if item.get_meta("readonly"):
        component = self._readonly_components[item.get_meta("idx")]
    else:
        component = self._components[item.get_meta("idx")]
    self._component_detail.set_component(component)

func _on_button_clicked(item: TreeItem, column: int, id: int, mouse_button_idx: int) -> void:
    match id:
        _BTN_ID_REMOVE:
            var comp: Component = self._components[item.get_meta("idx")]
            self._components.remove_at(item.get_meta("idx"))
            self._components.sort_custom(Licenses.compare_components_ascending)
            self.components_changed.emit()
            # refresh detail view if the current component was removed
            if comp == self._component_detail.get_component():
                self._component_detail.set_component(null)
            self.reload()

# callback from commponent detail tree
func _on_component_edited(component: Component) -> void:
    self._components.sort_custom(Licenses.compare_components_ascending)
    self.components_changed.emit()
    self.reload()

func _on_item_edited() -> void:
    var category_item: TreeItem = self.get_edited()
    var old_category: String = category_item.get_meta("category")
    var new_category: String = category_item.get_text(0)
    category_item.set_meta("category", new_category)
    for component: Component in self._components:
        if component.category == old_category:
            component.category = new_category

    self._components.sort_custom(Licenses.compare_components_ascending)
    self.components_changed.emit()
    # we cannot reload the tree while it is processing any kind of input/signals
    # https://github.com/godotengine/godot/issues/50084
    call_deferred("reload")
    # reload detail view as the category can be changed
    self._component_detail.reload()
