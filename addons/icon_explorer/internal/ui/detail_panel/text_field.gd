@tool
extends "res://addons/icon_explorer/internal/ui/detail_panel/field.gd"

@export var text: String:
    set = set_text
@export var uri: String:
    set = set_uri

@export var _label: Label
@export var _button: Button

func set_text(new_text: String) -> void:
    text = new_text
    if self._label != null:
        self._label.text = new_text
        self._label.tooltip_text = new_text
        self.visible = new_text != "" || self.uri != ""

func set_uri(new_uri: String) -> void:
    uri = new_uri
    if self._button != null:
        self._button.tooltip_text = new_uri
        self._button.visible = new_uri != ""
        self.visible = new_uri != "" || self.text != ""

func _ready() -> void:
    super._ready()
    if Engine.is_editor_hint():
        self._button.icon = self.get_theme_icon(&"ExternalLink", &"EditorIcons")
    self._button.pressed.connect(self._on_pressed)
    self.text = self.text
    self.uri = self.uri

func _on_pressed() -> void:
    OS.shell_open(self.uri)
