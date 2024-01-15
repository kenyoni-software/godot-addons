@tool
extends EditorPlugin

const QrCodeRect := preload("res://addons/qr_code/qr_code_rect.gd")

func _enter_tree() -> void:
    self.add_custom_type("QRCodeRect", "TextureRect", QrCodeRect, preload("res://addons/qr_code/qr_code.svg"))

func _exit_tree() -> void:
    self.remove_custom_type("QRCodeRect")
