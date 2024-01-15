@tool
extends "res://addons/icon_explorer/internal/ui/detail_panel/field.gd"

@export var color: Color = Color.WHITE:
    set = set_color

@export var _color_rect: ColorRect
@export var _color_label: Label

func set_color(new_color: Color) -> void:
    color = new_color
    if self._color_rect != null:
        self._color_rect.color = new_color
        self._color_label.text = "#" + new_color.to_html(false).to_upper()
        if (new_color.r * 0.299 + new_color.g * 0.587 + new_color.b * 0.114) > 186.0 / 255.0:
            self._color_label.add_theme_color_override(&"font_color", Color.BLACK)
        else:
            self._color_label.add_theme_color_override(&"font_color", Color.WHITE)

func _ready() -> void:
    super._ready()
    self.color = self.color
    self._color_rect.gui_input.connect(self._on_color_panel_gui_input)

func _on_color_panel_gui_input(event: InputEvent) -> void:
    if !((event is InputEventMouseButton) && (event as InputEventMouseButton).pressed && (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT):
        return
    self._color_rect.accept_event()
    DisplayServer.clipboard_set("#" + self._color_rect.color.to_html(false).to_upper())
