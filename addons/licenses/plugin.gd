@tool
extends EditorPlugin

const LicensesDialogScene: PackedScene = preload("internal/licenses_dialog.tscn")
const Licenses := preload("licenses.gd")
const ExportPlugin := preload("export_plugin.gd")

var export_plugin: ExportPlugin
var licenses_dialog: Window

func _get_plugin_name() -> String:
    return "Licenses"

func _enter_tree() -> void:
    set_project_setting(Licenses.DATA_FILE, "res://licenses.json", TYPE_STRING, PROPERTY_HINT_FILE)

    self.export_plugin = ExportPlugin.new()
    self.add_export_plugin(self.export_plugin)

    self.licenses_dialog = LicensesDialogScene.instantiate()
    EditorInterface.get_base_control().add_child(self.licenses_dialog)
    self.add_tool_menu_item(self._get_plugin_name() + "...", self._show_popup)

func _exit_tree() -> void:
    self.remove_tool_menu_item(self._get_plugin_name() + "...")
    self.licenses_dialog.queue_free()
    self.remove_export_plugin(self.export_plugin)

func _show_popup() -> void:
    if licenses_dialog.visible:
        self.licenses_dialog.grab_focus()
    else:
        self.licenses_dialog.popup_centered_ratio(0.4)

static func set_project_setting(key: String, initial_value, type: int, type_hint: int) -> void:
    if not ProjectSettings.has_setting(key):
        ProjectSettings.set_setting(key, initial_value)
    ProjectSettings.set_initial_value(key, initial_value)
    ProjectSettings.add_property_info({
        "name": key,
        "type": type,
        "hint": type_hint,
    })
