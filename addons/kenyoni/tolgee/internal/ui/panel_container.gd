@tool
extends PanelContainer

func _ready() -> void:
    self.add_theme_stylebox_override(&"panel", self.get_theme_stylebox(&"Background", &"EditorStyles"))
