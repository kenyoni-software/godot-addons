@tool
extends Window

const LicensesContainer := preload("res://addons/licenses/internal/licenses.gd")
const LicensesInterface := preload("res://addons/licenses/internal/plugin/licenses_interface.gd")

@export var _licenses: LicensesContainer

func _notification(what: int) -> void:
    if (what == NOTIFICATION_WM_CLOSE_REQUEST):
        self.hide()

func _on_about_to_popup() -> void:
    self._licenses.reload()

func set_licenses_interface(li: LicensesInterface) -> void:
    self._licenses.set_licenses_interface(li)
