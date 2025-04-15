@tool
extends EditorPlugin

const Licenses := preload("res://addons/licenses/licenses.gd")
const ExportPlugin := preload("res://addons/licenses/internal/plugin/export_plugin.gd")
const LicensesInterface := preload("res://addons/licenses/internal/plugin/licenses_interface.gd")
const ContextMenuFilesystem := preload("res://addons/licenses/internal/plugin/context_menu_filesystem.gd")
const FileSystemWatcher := preload("res://addons/licenses/internal/plugin/file_system_watcher.gd")

var _export_plugin: ExportPlugin
var _context_menu_filesystem: ContextMenuFilesystem
var _file_watcher: FileSystemWatcher

func _get_plugin_name() -> String:
    return "Licenses"

func _enter_tree() -> void:
    set_project_setting(Licenses.CFG_KEY_DATA_FILE, "res://licenses.json", TYPE_STRING, PROPERTY_HINT_FILE)
    ProjectSettings.set_as_basic(Licenses.CFG_KEY_DATA_FILE, true)
    set_project_setting(Licenses.CFG_KEY_INDENTATION, 0, TYPE_INT, PROPERTY_HINT_ENUM, "None,Spaces,Tabs")
    LicensesInterface.create_interface()
    LicensesInterface.get_interface().load_licenses(Licenses.get_license_data_filepath())
    self._file_watcher = FileSystemWatcher.new()

    self._export_plugin = ExportPlugin.new()
    self.add_export_plugin(self._export_plugin)

    self.add_tool_menu_item(self._get_plugin_name() + "...", LicensesInterface.get_interface().show_popup)
    self._context_menu_filesystem = ContextMenuFilesystem.new()
    self.add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM, self._context_menu_filesystem)

func _exit_tree() -> void:
    self.remove_context_menu_plugin(self._context_menu_filesystem)
    self.remove_tool_menu_item(self._get_plugin_name() + "...")
    self.remove_export_plugin(self._export_plugin)
    self._file_watcher = null
    LicensesInterface.remove_interface()

static func set_project_setting(key: String, initial_value, type: Variant.Type, type_hint: PropertyHint, hint_string: String = "") -> void:
    if not ProjectSettings.has_setting(key):
        ProjectSettings.set_setting(key, initial_value)
    ProjectSettings.set_initial_value(key, initial_value)
    var props: Dictionary = {
        "name": key,
        "type": type,
        "hint": type_hint,
    }
    if hint_string != "":
        props["hint_string"] = hint_string
    ProjectSettings.add_property_info(props)
