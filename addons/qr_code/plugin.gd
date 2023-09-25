@tool
extends EditorPlugin

func _enter_tree() -> void:
    self.add_custom_type("QRCodeRect", "TextureRect", preload("qr_code_rect.gd"), preload("qr_code.svg"))

func _exit_tree() -> void:
    self.remove_custom_type("QRCodeRect")
