@tool
extends Window

const Component := preload("res://addons/licenses/component.gd")
const Licenses := preload("res://addons/licenses/internal/licenses.gd")

@export var _licenses: Licenses

func _notification(what: int) -> void:
    if (what == NOTIFICATION_WM_CLOSE_REQUEST):
        self.hide()

func show_component(comp: Component) -> void:
    self._licenses.show_component(comp)
