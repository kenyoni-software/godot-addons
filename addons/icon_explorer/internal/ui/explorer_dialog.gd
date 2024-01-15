@tool
extends Window

const Explorer := preload("res://addons/icon_explorer/internal/ui/explorer/explorer.gd")

@export var _explorer_path: NodePath
@onready var _explorer: Explorer = self.get_node(self._explorer_path)

func _notification(what: int) -> void:
    if (what == NOTIFICATION_WM_CLOSE_REQUEST):
        self.hide()

func _on_about_to_popup() -> void:
    if Engine.is_editor_hint() && !ProjectSettings.get_setting("plugins/icon_explorer/load_on_startup", false):
        self._explorer.load_db()
