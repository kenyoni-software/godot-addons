@tool
extends EditorPlugin

const TextureButtonColored := preload("res://addons/texture_button_colored/texture_button_colored.gd")

func _enter_tree() -> void:
    self.add_custom_type("TextureButtonColored", "TextureButton", TextureButtonColored, preload("res://addons/texture_button_colored/texture_button_colored.svg"))

func _exit_tree() -> void:
    self.remove_custom_type("TextureButtonColored")
