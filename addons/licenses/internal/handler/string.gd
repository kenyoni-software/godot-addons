extends "res://addons/licenses/internal/handler/base.gd"

func _init(tree_: ComponentDetailTree, item_: TreeItem, value_: Variant, property_: Dictionary) -> void:
    super._init(tree_, item_, value_, property_)
    self.item.set_text(0, self.property["name"].capitalize())
    self.item.set_text(1, value_)
    self.item.set_editable(1, true)
    self._update_reset_button()

static func can_handle(property: Dictionary) -> bool:
    return property["type"] == TYPE_STRING

func _update_reset_button() -> void:
    var button_id: int = self.item.get_button_by_id(0, 0)
    if self.value != "" && button_id == -1:
        self.item.add_button(0, self.tree.get_theme_icon(&"Reload", &"EditorIcons"), 0)
    elif self.value == "" && button_id != -1:
        self.item.erase_button(0, button_id)

func button_clicked(column: int, id: int, mouse_button_idx: int) -> void:
    self.value = ""
    self.item.set_text(1, "")
    self._update_reset_button()
    self.tree._on_item_edited(self.item)

func edited() -> void:
    self.value = self.item.get_text(1)
    self._update_reset_button()
