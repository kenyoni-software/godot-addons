extends "res://addons/licenses/internal/handler/base.gd"

func _init(tree_: ComponentDetailTree, item_: TreeItem, value_: Variant, property_: Dictionary) -> void:
    super._init(tree_, item_, value_, property_)
    self.item.set_text(0, self.property["name"].capitalize())
    self.item.set_text(1, self.value)
    self.item.set_editable(1, true)
    self._update_reset_button()
    self.item.add_button(1, self.tree.get_theme_icon(&"Load", &"EditorIcons"), 1)

static func can_handle(property: Dictionary) -> bool:
    return property["type"] == TYPE_STRING && property.get("hint", PROPERTY_HINT_NONE) == PROPERTY_HINT_FILE

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
            var dialog: EditorFileDialog = EditorFileDialog.new()
            self.tree.add_child(dialog)
            if property.get("hint_text", "") == "*":
                dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_ANY
            else:
                dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
            dialog.close_requested.connect(dialog.queue_free)
            dialog.file_selected.connect(self._on_path_selected)
            dialog.dir_selected.connect(self._on_path_selected)
            dialog.popup_centered_ratio(0.4)

func _on_path_selected(path: String) -> void:
    self.value = path
    self.item.set_text(1, self.value)
    self._update_reset_button()
    self.tree._on_item_edited(self.item)

func edited() -> void:
    self.value = self.item.get_text(1)
    self._update_reset_button()
