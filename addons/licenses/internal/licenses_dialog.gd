@tool
extends Window

const LicensesContainer := preload("res://addons/licenses/internal/licenses.gd")

@export var _licenses: LicensesContainer

func _notification(what: int) -> void:
    if (what == NOTIFICATION_WM_CLOSE_REQUEST):
        self.hide()

func _on_about_to_popup() -> void:
    self._licenses.reload()
