@tool
extends EditorPlugin

const ExplorerDialogScene: PackedScene = preload("res://addons/icon_explorer/internal/ui/explorer_dialog.tscn")

var _explorer_dialog: Window

func _get_plugin_name() -> String:
    return "Icon Explorer"

func _enter_tree() -> void:
    set_project_setting("plugins/icon_explorer/load_on_startup", false, TYPE_BOOL, PROPERTY_HINT_NONE)
    set_project_setting("plugins/icon_explorer/preview_size_exp", 6, TYPE_INT, PROPERTY_HINT_RANGE, "4,8,1")

    self._explorer_dialog = ExplorerDialogScene.instantiate()
    EditorInterface.get_base_control().add_child(self._explorer_dialog)
    self.add_tool_menu_item(self._get_plugin_name() + "...", self._show_popup)

func _exit_tree() -> void:
    self.remove_tool_menu_item(self._get_plugin_name() + "...")
    self._explorer_dialog.queue_free()

func _show_popup() -> void:
    if self._explorer_dialog.visible:
        self._explorer_dialog.grab_focus()
    else:
        self._explorer_dialog.popup_centered_ratio(0.4)

static func set_project_setting(key: String, initial_value, type: int, type_hint: int, hint_string: String = "") -> void:
    if not ProjectSettings.has_setting(key):
        ProjectSettings.set_setting(key, initial_value)
    ProjectSettings.set_initial_value(key, initial_value)
    ProjectSettings.add_property_info({
        "name": key,
        "type": type,
        "hint": type_hint,
        "hint_string": type_hint,
    })
