@tool
extends EditorPlugin

const TextureButtonColored := preload("res://addons/texture_button_colored/texture_button_colored.gd")

func _enable_plugin() -> void:
    if !EditorInterface.is_plugin_enabled("custom_theme_overrides"):
        EditorInterface.set_plugin_enabled("custom_theme_overrides", true)
        if !EditorInterface.is_plugin_enabled("custom_theme_overrides"):
            EditorInterface.set_plugin_enabled("texture_button_colored", false)
            push_error("TextureButtonColored requires CustomThemeOverrides plugin! Which is not installed.")
        else:
            print("TextureButtonColored requires CustomThemeOverrides plugin! Enabled dependency.")

func _enter_tree() -> void:
    self.add_custom_type("TextureButtonColored", "TextureButton", TextureButtonColored, preload("res://addons/texture_button_colored/texture_button_colored.svg"))

func _exit_tree() -> void:
    self.remove_custom_type("TextureButtonColored")
