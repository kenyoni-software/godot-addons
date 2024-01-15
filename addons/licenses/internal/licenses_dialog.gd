@tool
extends Window

const LicensesContainer := preload("res://addons/licenses/internal/licenses.gd")

@export_node_path("MarginContainer") var _licenses_path; @onready var _licenses: LicensesContainer = self.get_node(self._licenses_path)

func _notification(what: int) -> void:
    if (what == NOTIFICATION_WM_CLOSE_REQUEST):
        self.hide()

func _on_about_to_popup() -> void:
    self._licenses.reload()
