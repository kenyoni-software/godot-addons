@tool
extends EditorPlugin

func _enter_tree() -> void:
    self.add_custom_type("QRCodeTexture", "ImageTexture", preload("qr_code_texture.gd"), preload("qr_code.svg"))

func _exit_tree() -> void:
    self.remove_custom_type("QRCodeTexture")
