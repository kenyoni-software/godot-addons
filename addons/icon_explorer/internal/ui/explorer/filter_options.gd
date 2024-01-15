@tool
extends MenuButton

signal options_changed()

func _ready() -> void:
	var popup: PopupMenu = self.get_popup()
	popup.hide_on_checkable_item_selection = false
	popup.index_pressed.connect(self._on_index_pressed)
		
func _on_index_pressed(idx: int) -> void:
	var popup: PopupMenu = self.get_popup()
	popup.set_item_checked(idx, !popup.is_item_checked(idx))
	self.options_changed.emit()
