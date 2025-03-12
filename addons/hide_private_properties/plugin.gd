@tool
extends EditorPlugin

const InspectorPlugin := preload("res://addons/hide_private_properties/inspector_plugin.gd")
const Utils := preload("res://addons/hide_private_properties/utils.gd")
const DialogScene: PackedScene = preload("res://addons/hide_private_properties/internal/dialog.tscn")

const CFG_KEY_HIDE_PRIVATE_PROPERTIES: String = "interface/inspector/hide_private_properties"

var _inspector_plugin: InspectorPlugin
var _dialog: Window

func _enter_tree() -> void:
    self._init_editor_settings()
    EditorInterface.get_editor_settings().settings_changed.connect(self._on_settings_changed)

    self._dialog = DialogScene.instantiate()
    self.add_child(self._dialog)
    self._dialog.about_to_popup.connect(self._on_dialog_about_to_popup)
    self._dialog.close_requested.connect(self._on_dialog_close_requested)

    self.add_tool_menu_item("Scan for private property overrides...", self._on_tool_menu)

    self._inspector_plugin = InspectorPlugin.new()
    self._inspector_plugin.hide_private_properties = EditorInterface.get_editor_settings().get_setting(CFG_KEY_HIDE_PRIVATE_PROPERTIES)
    self.add_inspector_plugin(self._inspector_plugin)

func _exit_tree() -> void:
    EditorInterface.get_editor_settings().settings_changed.disconnect(self._on_settings_changed)
    self.remove_inspector_plugin(self._inspector_plugin)
    self.remove_tool_menu_item("Scan for private property overrides...")
    self.remove_child(self._dialog)
    self._dialog.free()
    self._dialog = null

func _init_editor_settings() -> void:
    var editor_settings: EditorSettings = EditorInterface.get_editor_settings()
    if editor_settings.has_setting(CFG_KEY_HIDE_PRIVATE_PROPERTIES):
        return
    editor_settings.set_setting(CFG_KEY_HIDE_PRIVATE_PROPERTIES, true)
    editor_settings.set_initial_value(CFG_KEY_HIDE_PRIVATE_PROPERTIES, true, true)
    # "Hide private properties of instantiated scenes in the inspector."
    editor_settings.add_property_info({
        "name": CFG_KEY_HIDE_PRIVATE_PROPERTIES,
        "type": TYPE_BOOL,
    })
    editor_settings.mark_setting_changed(CFG_KEY_HIDE_PRIVATE_PROPERTIES)

func _on_tool_menu() -> void:
    self._dialog.popup_centered_ratio(0.4)

func _on_dialog_about_to_popup() -> void:
    self._inspector_plugin.hide_private_properties = false

func _on_dialog_close_requested() -> void:
    self._dialog.visible = false
    self._inspector_plugin.hide_private_properties = EditorInterface.get_editor_settings().get_setting(CFG_KEY_HIDE_PRIVATE_PROPERTIES)

func _on_settings_changed() -> void:
    ## change only if dialog is not visible
    if !self._dialog.visible:
        self._inspector_plugin.hide_private_properties = EditorInterface.get_editor_settings().get_setting(CFG_KEY_HIDE_PRIVATE_PROPERTIES)
