@tool
extends EditorPlugin

const MenuScene := preload("res://addons/kenyoni/tolgee/internal/ui/menu.tscn")
const Tolgee := preload("res://addons/kenyoni/tolgee/internal/scripts/tolgee.gd")

var _menu: Control

func _enter_tree() -> void:
    print(Tolgee.bcp47_to_locale("fr-CA"))
    self._init_project_settings(Tolgee.CFG_KEY_HOST, TYPE_STRING, "https://app.tolgee.io")
    ProjectSettings.set_as_basic(Tolgee.CFG_KEY_HOST, true)
    self._init_project_settings(Tolgee.CFG_KEY_API_KEY, TYPE_STRING, "", PROPERTY_HINT_PASSWORD)
    ProjectSettings.set_as_basic(Tolgee.CFG_KEY_API_KEY, true)
    self._init_project_settings(Tolgee.CFG_KEY_UPLOAD_ADD_NEW, TYPE_BOOL, true)
    ProjectSettings.set_as_internal(Tolgee.CFG_KEY_FILES, true)
    self._init_project_settings(Tolgee.CFG_KEY_UPLOAD_REMOVE_MISSING, TYPE_BOOL, true)
    ProjectSettings.set_as_internal(Tolgee.CFG_KEY_FILES, true)
    self._init_project_settings(Tolgee.CFG_KEY_UPLOAD_OVERRIDE_EXISTING, TYPE_BOOL, true)
    ProjectSettings.set_as_internal(Tolgee.CFG_KEY_FILES, true)
    self._init_project_settings(Tolgee.CFG_KEY_FILES, TYPE_DICTIONARY, {})
    ProjectSettings.set_as_internal(Tolgee.CFG_KEY_FILES, true)

    Tolgee.init()
    self.add_child(Tolgee.interface())

    self._menu = MenuScene.instantiate()
    var proj_settings: Node = EditorInterface.get_base_control().find_child("*ProjectSettingsEditor*", true, false)
    var localization: Control = proj_settings.get_child(0).get_child(2)
    var localization_tabs: TabContainer = localization.get_child(0) as TabContainer
    localization_tabs.add_child(self._menu)
    localization_tabs.set_tab_title(localization_tabs.get_tab_count() - 1, "Tolgee")

    Tolgee.interface().validate()

func _exit_tree() -> void:
    self._menu.get_parent().remove_child(self._menu)
    self._menu.free()
    self.remove_child(Tolgee.interface())
    Tolgee.interface().free()

func _init_project_settings(key: String, type: Variant.Type, default_value: Variant, type_hint: PropertyHint = PROPERTY_HINT_NONE) -> void:
    var props: Dictionary = {
        "name": key,
        "type": type,
    }
    if type_hint != PROPERTY_HINT_NONE:
        props["hint"] = type_hint
    if !ProjectSettings.has_setting(key):
        ProjectSettings.set_setting(key, default_value)
    ProjectSettings.set_initial_value(key, default_value)
    ProjectSettings.add_property_info(props)
