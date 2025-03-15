@tool
extends EditorPlugin

const MenuScene := preload("res://addons/kenyoni/pot_generation/menu.tscn")
const Utils := preload("res://addons/kenyoni/pot_generation/utils.gd")

var _menu: Control

func _get_plugin_name() -> String:
    return "POT Generation"

func _enter_tree() -> void:
    Utils._init()
    self._menu = MenuScene.instantiate()
    var proj_settings: Node = EditorInterface.get_base_control().find_child("*ProjectSettingsEditor*", true, false)
    var localization: Control = proj_settings.get_child(0).get_child(2)
    var localization_tabs: TabContainer = localization.get_child(0) as TabContainer
    localization_tabs.add_child(self._menu)
    localization_tabs.set_tab_title(localization_tabs.get_tab_count() - 1, tr("POT Generation"))
    # hide original POT Generation menu
    localization_tabs.set_tab_hidden(2, true)

func _exit_tree() -> void:
    self._menu.get_parent().set_tab_hidden(2, false)
    self._menu.get_parent().remove_child(self._menu)
    self._menu.free()
