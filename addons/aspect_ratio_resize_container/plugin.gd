@tool
extends EditorPlugin

const AspectRationResizeContainer := preload("res://addons/aspect_ratio_resize_container/aspect_ratio_resize_container.gd")

func _enter_tree() -> void:
    self.add_custom_type("AspectRatioResizeContainer", "AspectRatioContainer", AspectRationResizeContainer, preload("res://addons/aspect_ratio_resize_container/icon.svg"))

func _exit_tree() -> void:
    self.remove_custom_type("AspectRatioResizeContainer")
