@tool
extends Tree

const Component := preload("res://addons/licenses/component.gd")

signal component_edited(component: Component)

enum BUTTON_ID {
    RESET = 1,
    MULTI_LINE_STR = 2,
    FILE_DIALOG = 3
}

@export var _nothing_selected_note: CenterContainer
var _component: Component:
    set = set_component,
    get = get_component
var handlers: Array[GDScript] = []
var _selected_item: TreeItem = null

func set_component(new_component: Component) -> void:
    if _component == new_component:
        return
    _component = new_component
    self._nothing_selected_note.visible = _component == null
    self.reload()

func get_component() -> Component:
    return _component

func _init() -> void:
    self.set_column_expand(0, false)
    var min_width: float = \
        self.get_theme_font(&"font").get_string_size("Identifier", 0, -1, self.get_theme_font_size(&"font_size")).x \
        + self.get_theme_constant(&"inner_item_margin_left") \
        + self.get_theme_constant(&"inner_item_margin_right") \
        + self.get_theme_constant(&"item_margin") \
        # around 2x arrow and one button size
        + 3 * self.get_theme_icon(&"arrow").get_size().x
    # add 5% space to be safe
    min_width = 1.05 * min_width
    self.set_column_custom_minimum_width(0, min_width)
    self.set_column_clip_content(1, true)

func reload() -> void:
    self._selected_item = null
    self.clear()
    if self._component == null:
        return
    self._add_item(null, self._component, {"name": "component", "type": TYPE_OBJECT})
    if _component.readonly:
        self.set_readonly(self.get_root())

func set_readonly(item: TreeItem) -> void:
    for column: int in range(self.columns):
        item.set_editable(column, false)
        for idx: int in range(item.get_button_count(column)):
            item.erase_button(column, 0)
    for child: TreeItem in item.get_children():
        self.set_readonly(child)
    if item.get_next() != null:
        self.set_readonly(item.get_next())

func _on_button_clicked(item: TreeItem, column: int, id: int, mouse_button_idx: int) -> void:
    item.get_meta("handler").button_clicked(column, id, mouse_button_idx)

func _on_cell_selected() -> void:
    if self._selected_item != null:
        self._selected_item.clear_custom_bg_color(0)
    self._selected_item = self.get_selected()
    self._selected_item.set_custom_bg_color(0, self.get_theme_color(&"box_selection_fill_color", &"Editor"))
    if self.get_selected_column() == 0:
        self._selected_item.deselect(0)
        self._selected_item.select(1)

func _on_item_edited(item: TreeItem = null) -> void:
    if item == null:
        item = self.get_edited()
    var handler = item.get_meta("handler")
    handler.edited()
    var parent: TreeItem = item.get_parent()
    if parent != null:
        parent.get_meta("handler").child_edited(item)

    self.component_edited.emit(self._component)

func _get_handler(property: Dictionary) -> GDScript:
    for handler: GDScript in self.handlers:
        if handler.can_handle(property):
            return handler
    return null

func _add_item(parent: TreeItem, value: Variant, property: Dictionary) -> void:
    var handler_cls: GDScript = self._get_handler(property)
    if handler_cls == null:
        return
    handler_cls.new(self, self.create_item(parent), value, property)
