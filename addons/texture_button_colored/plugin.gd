@tool
extends EditorPlugin

const TextureButtonColored := preload("res://addons/texture_button_colored/texture_button_colored.gd")
const EditorToastNotification := preload("res://addons/texture_button_colored/editor_toast_notification.gd")

func _enable_plugin() -> void:
    if !EditorInterface.is_plugin_enabled("custom_theme_overrides"):
        EditorInterface.set_plugin_enabled("custom_theme_overrides", true)
        if !EditorInterface.is_plugin_enabled("custom_theme_overrides"):
            EditorInterface.set_plugin_enabled("texture_button_colored", false)
            EditorToastNotification.notify("TextureButtonColored requires CustomThemeOverrides plugin! Which is not installed.", EditorToastNotification.Severity.ERROR)
        else:
            EditorToastNotification.notify("TextureButtonColored requires CustomThemeOverrides plugin! Enabled dependency.")

func _enter_tree() -> void:
    self.add_custom_type("TextureButtonColored", "TextureButton", TextureButtonColored, preload("res://addons/texture_button_colored/texture_button_colored.svg"))

func _exit_tree() -> void:
    self.remove_custom_type("TextureButtonColored")
