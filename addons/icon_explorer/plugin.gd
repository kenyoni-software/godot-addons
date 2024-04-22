@tool
extends EditorPlugin

const ExplorerScene: PackedScene = preload("res://addons/icon_explorer/internal/ui/explorer/explorer.tscn")
const ExplorerDialog := preload("res://addons/icon_explorer/internal/ui/explorer_dialog.gd")
const ExplorerDialogScene: PackedScene = preload("res://addons/icon_explorer/internal/ui/explorer_dialog.tscn")
const MainScreen := preload("res://addons/icon_explorer/internal/ui/main_screen.gd")
const MainScreenScene := preload("res://addons/icon_explorer/internal/ui/main_screen.tscn")
const IconDatabase := preload("res://addons/icon_explorer/internal/scripts/database.gd")

var _explorer_dialog: ExplorerDialog
var _main_screen: MainScreen = null

var _db: IconDatabase
var _db_loaded: bool = false

func _get_plugin_name() -> String:
    return "Icon Explorer"

func _get_plugin_icon() -> Texture2D:
    return preload("res://addons/icon_explorer/icon.svg")

func _enter_tree() -> void:
    set_project_setting("plugins/icon_explorer/load_on_startup", false, TYPE_BOOL, PROPERTY_HINT_NONE)
    set_project_setting("plugins/icon_explorer/show_main_screen", true, TYPE_BOOL, PROPERTY_HINT_NONE)
    ProjectSettings.set_restart_if_changed("plugins/icon_explorer/show_main_screen", true)
    set_project_setting("plugins/icon_explorer/preview_size_exp", 6, TYPE_INT, PROPERTY_HINT_RANGE, "4,8,1")

    self._explorer_dialog = ExplorerDialogScene.instantiate()
    EditorInterface.get_base_control().add_child(self._explorer_dialog)
    self.add_tool_menu_item(self._get_plugin_name() + "...", self._show_popup)

    self._db = IconDatabase.new(self.get_tree())
    self._explorer_dialog.set_icon_db(self._db)
    if self._has_main_screen():
        self._main_screen = MainScreenScene.instantiate()
        self._main_screen.set_icon_db(self._db)
        EditorInterface.get_editor_main_screen().add_child(self._main_screen)
        self._main_screen.hide()

    if ProjectSettings.get_setting("plugins/icon_explorer/load_on_startup", false):
        self._db.load()

func _exit_tree() -> void:
    if self._main_screen != null:
        EditorInterface.get_editor_main_screen().remove_child(self._main_screen)
        self._main_screen.queue_free()
    self.remove_tool_menu_item(self._get_plugin_name() + "...")
    self._explorer_dialog.queue_free()

func _has_main_screen() -> bool:
    return ProjectSettings.get_setting("plugins/icon_explorer/show_main_screen", true)

func _make_visible(visible: bool) -> void:
    if !self._db_loaded:
        self._db_loaded = true
        self._db.load()
    self._main_screen.visible = visible

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
        "hint_string": hint_string,
    })
