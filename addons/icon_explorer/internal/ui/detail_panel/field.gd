@tool
extends VBoxContainer

const FieldTitle := preload("res://addons/icon_explorer/internal/ui/detail_panel/field_title.gd")

@export var title: String:
    set = set_title

@export var _title_path: NodePath
@onready var _title: FieldTitle = self.get_node(self._title_path)

func set_title(new_title: String) -> void:
    title = new_title
    if self._title != null:
        self._title.text = new_title

func _ready() -> void:
    self.title = self.title
