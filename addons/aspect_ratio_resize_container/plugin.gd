@tool
extends EditorPlugin

func _enter_tree() -> void:
    self.add_custom_type("AspectRatioResizeContainer", "AspectRatioContainer", preload("aspect_ratio_resize_container.gd"), preload("icon.svg"))

func _exit_tree() -> void:
    self.remove_custom_type("AspectRatioResizeContainer")
