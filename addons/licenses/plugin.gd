@tool
extends EditorPlugin

const LicensesDialogScene: PackedScene = preload("res://addons/licenses/internal/licenses_dialog.tscn")
const LicensesDialog := preload("res://addons/licenses/internal/licenses_dialog.gd")
const Licenses := preload("res://addons/licenses/licenses.gd")
const ExportPlugin := preload("res://addons/licenses/internal/plugin/export_plugin.gd")
const LicensesInterface := preload("res://addons/licenses/internal/licenses_interface.gd")
const FileSystemWatcher := preload("res://addons/licenses/internal/plugin/file_system_watcher.gd")

var _export_plugin: ExportPlugin
var _licenses_dialog: Window
var _licenses_dialog: LicensesDialog
var _file_watcher: FileSystemWatcher

var _li: LicensesInterface

func _get_plugin_name() -> String:
    return "Licenses"

func _enter_tree() -> void:
    set_project_setting(Licenses.DATA_FILE, "res://licenses.json", TYPE_STRING, PROPERTY_HINT_FILE)
    self._li = LicensesInterface.new()
    self.add_child(self._li)
    self._file_watcher = FileSystemWatcher.new(self._li)

    self._export_plugin = ExportPlugin.new()
    self.add_export_plugin(self._export_plugin)

    self._licenses_dialog = LicensesDialogScene.instantiate()
    self._licenses_dialog.set_licenses_interface(self._li)
    EditorInterface.get_base_control().add_child(self._licenses_dialog)
    self.add_tool_menu_item(self._get_plugin_name() + "...", self._show_popup)

func _exit_tree() -> void:
    self.remove_tool_menu_item(self._get_plugin_name() + "...")
    self._licenses_dialog.queue_free()
    self.remove_export_plugin(self._export_plugin)
    self._li.queue_free()

func _show_popup() -> void:
    if _licenses_dialog.visible:
        self._licenses_dialog.grab_focus()
    else:
        self._licenses_dialog.popup_centered_ratio(0.4)

static func set_project_setting(key: String, initial_value, type: int, type_hint: int) -> void:
    if not ProjectSettings.has_setting(key):
        ProjectSettings.set_setting(key, initial_value)
    ProjectSettings.set_initial_value(key, initial_value)
    ProjectSettings.add_property_info({
        "name": key,
        "type": type,
        "hint": type_hint,
    })
