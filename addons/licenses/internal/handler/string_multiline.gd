extends "res://addons/licenses/internal/handler/base.gd"

var _dialog: AcceptDialog

func _init(tree_: ComponentDetailTree, item_: TreeItem, value_: Variant, property_: Dictionary) -> void:
    super._init(tree_, item_, value_, property_)
    self.item.set_text(0, self.property["name"].capitalize())
    self.item.set_text(1, self.value)
    var tooltip_text: String = self.value.substr(0, mini(self.value.length(), 512))
    if self.value.length() > 512:
        tooltip_text += "..."
    self.item.set_tooltip_text(1, tooltip_text)
    self._update_reset_button()
    self.item.add_button(1, self.tree.get_theme_icon(&"DistractionFree", &"EditorIcons"), 1)

static func can_handle(property: Dictionary) -> bool:
    return property["type"] == TYPE_STRING && property.get("hint", PROPERTY_HINT_NONE) == PROPERTY_HINT_MULTILINE_TEXT

func _update_reset_button() -> void:
    var button_id: int = self.item.get_button_by_id(0, 0)
    if self.value != "" && button_id == -1:
        self.item.add_button(0, self.tree.get_theme_icon(&"Reload", &"EditorIcons"), 0)
    elif self.value == "" && button_id != -1:
        self.item.erase_button(0, button_id)

func button_clicked(column: int, id: int, mouse_button_idx: int) -> void:
    match id:
        0:
            self.value = ""
            self.item.set_text(1, self.value)
            self._update_reset_button()
            self.tree._on_item_edited(self.item)
        1:
            self._dialog = AcceptDialog.new()
            self._dialog.title = "Edit Text:"
            self._dialog.unresizable = false
            var margin_cont: MarginContainer = MarginContainer.new()
            margin_cont.anchor_right = 1
            margin_cont.anchor_bottom = 0.913
            self._dialog.add_child(margin_cont)
            var edit_text: TextEdit = TextEdit.new()
            edit_text.text = self.value
            margin_cont.add_child(edit_text)

            self.tree.add_child(self._dialog)
            var view_size: Vector2 = self.tree.get_viewport().size
            self._dialog.popup_centered_ratio(0.4)
            self._dialog.confirmed.connect(self._on_text_edited)

func _on_text_edited() -> void:
    self.value = self._dialog.get_child(0).get_child(0).text
    self.item.set_text(1, self.value)
    self._update_reset_button()
    self._dialog.queue_free()
    self.tree._on_item_edited(self.item)
