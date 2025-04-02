@tool
extends EditorPlugin

const MenuScene := preload("res://addons/kenyoni/tolgee/internal/ui/menu.tscn")
const Tolgee := preload("res://addons/kenyoni/tolgee/internal/scripts/tolgee.gd")

var _menu: Control

func _enter_tree() -> void:
    self._init_project_settings(Tolgee.CFG_KEY_HOST, TYPE_STRING, "")
    self._init_project_settings(Tolgee.CFG_KEY_API_KEY, TYPE_STRING, "", PROPERTY_HINT_PASSWORD)
    self._init_project_settings(Tolgee.CFG_KEY_LIVE_SYNC, TYPE_BOOL, true)
    self._init_project_settings(Tolgee.CFG_KEY_LOCALIZATION, TYPE_STRING, Tolgee.LOCALIZATION_NONE, PROPERTY_HINT_ENUM, ",".join([Tolgee.LOCALIZATION_NONE, Tolgee.LOCALIZATION_CSV, Tolgee.LOCALIZATION_GETTEXT]))
    self._init_project_settings(Tolgee.CFG_KEY_PO_OUT_DIRECTORY, TYPE_STRING, "", PROPERTY_HINT_DIR)
    self._init_project_settings(Tolgee.CFG_KEY_POT_FILES, TYPE_ARRAY, [], PROPERTY_HINT_ARRAY_TYPE, "%d/%d:%s" % [TYPE_STRING, PROPERTY_HINT_FILE, "*.pot"])
    self._init_project_settings(Tolgee.CFG_KEY_CSV_FILES, TYPE_ARRAY, [], PROPERTY_HINT_ARRAY_TYPE, "%d/%d:%s" % [TYPE_STRING, PROPERTY_HINT_FILE, "*.csv"])
    self._init_project_settings(Tolgee.CFG_KEY_PLACEHOLDER, TYPE_STRING, Tolgee.PLACEHOLDER_ICU, PROPERTY_HINT_ENUM, ",".join([Tolgee.PLACEHOLDER_ICU, Tolgee.PLACEHOLDER_PHP, Tolgee.PLACEHOLDER_JAVA]))

    Tolgee.init()
    self.add_child(Tolgee.interface())
    Tolgee.interface().validate()

    self._menu = MenuScene.instantiate()
    var proj_settings: Node = EditorInterface.get_base_control().find_child("*ProjectSettingsEditor*", true, false)
    var localization: Control = proj_settings.get_child(0).get_child(2)
    var localization_tabs: TabContainer = localization.get_child(0) as TabContainer
    localization_tabs.add_child(self._menu)
    localization_tabs.set_tab_title(localization_tabs.get_tab_count() - 1, "Tolgee")

func _exit_tree() -> void:
    self._menu.get_parent().remove_child(self._menu)
    self._menu.free()
    self.remove_child(Tolgee.interface())
    Tolgee.interface().free()

func _init_project_settings(key: String, type: Variant.Type, default_value: Variant, type_hint: PropertyHint = PROPERTY_HINT_NONE, hint_string: String = "") -> void:
    var props: Dictionary = {
        "name": key,
        "type": type,
    }
    if type_hint != PROPERTY_HINT_NONE:
        props["hint"] = type_hint
    if hint_string != "":
        props["hint_string"] = hint_string
    if !ProjectSettings.has_setting(key):
        ProjectSettings.set_setting(key, default_value)
    ProjectSettings.set_initial_value(key, default_value)
    ProjectSettings.add_property_info(props)
    ProjectSettings.set_as_basic(key, true)
