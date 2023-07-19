@tool
extends EditorPlugin

func _enter_tree() -> void:
    self.add_custom_type("TextureButtonColored", "TextureButton", preload("texture_button_colored.gd"), preload("texture_button_colored.svg"))

func _exit_tree() -> void:
    self.remove_custom_type("TextureButtonColored")
