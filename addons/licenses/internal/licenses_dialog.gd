@tool
extends Window

const LicensesContainer := preload("res://addons/licenses/internal/licenses.gd")

@export var licenses: LicensesContainer

func _notification(what: int) -> void:
    if (what == NOTIFICATION_WM_CLOSE_REQUEST):
        self.hide()
