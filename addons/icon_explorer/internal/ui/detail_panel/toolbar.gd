@tool
extends HBoxContainer

signal save_pressed()
signal save_colored_pressed()

@export var _save_button: Button
@export var _save_colored_button: Button

func _ready() -> void:
    if Engine.is_editor_hint():
        self._save_button.icon = self.get_theme_icon(&"Save", &"EditorIcons")
        var save_colored_img: Image = self.get_theme_icon(&"Save", &"EditorIcons").get_image()
        var color_img: Image = self.get_theme_icon(&"StyleBoxFlat", &"EditorIcons").get_image()
        save_colored_img.blend_rect_mask(color_img, save_colored_img, Rect2i(Vector2i.ZERO, color_img.get_size()), Vector2i.ZERO)
        self._save_colored_button.icon = ImageTexture.create_from_image(save_colored_img)
    self._save_button.pressed.connect(self._on_save_button_pressed)
    self._save_colored_button.pressed.connect(self._on_save_colored_button_pressed)

func _on_save_button_pressed() -> void:
    self.save_pressed.emit()

func _on_save_colored_button_pressed() -> void:
    self.save_colored_pressed.emit()
