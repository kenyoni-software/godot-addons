@tool
extends PanelContainer

@export var text: String:
    set = set_text

@export var _text_label: Label

func set_text(new_text: String) -> void:
    text = new_text
    if self._text_label != null:
        self._text_label.text = new_text

func _ready() -> void:
    if Engine.is_editor_hint():
        self._text_label.add_theme_font_override(&"font", self.get_theme_font(&"title", &"EditorFonts"))
        var stylebox: StyleBox = self.get_theme_stylebox(&"PanelForeground", &"EditorStyles").duplicate()
        stylebox.content_margin_bottom = 0
        stylebox.content_margin_top = 0
        self.add_theme_stylebox_override(&"panel", stylebox)
    self.text = self.text
