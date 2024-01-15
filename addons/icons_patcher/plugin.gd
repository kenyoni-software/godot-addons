@tool
extends EditorPlugin

const ToolMenu := preload("tool_menu.gd")
const Utils := preload("utils.gd")

var tool_menu: ToolMenu

func _enter_tree() -> void:
    # Material Design Icons Directory
    Utils.init_project_setting(Utils.MDI_DIRECTORY_PATH, "", TYPE_STRING, PROPERTY_HINT_DIR)

    self.tool_menu = ToolMenu.new()
    self.add_tool_submenu_item("Icons Patcher", self.tool_menu)

func _exit_tree() -> void:
    self.remove_tool_menu_item("Icons Patcher")

func _disable_plugin() -> void:
    ProjectSettings.set_setting(Utils.MDI_DIRECTORY_PATH, null)
