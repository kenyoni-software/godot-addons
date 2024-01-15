@tool
extends VBoxContainer

const IconFontAwesome := preload("res://addons/icon_explorer/internal/scripts/collections/icon_font_awesome.gd")
const TextField := preload("res://addons/icon_explorer/internal/ui/detail_panel/text_field.gd")
const ListField := preload("res://addons/icon_explorer/internal/ui/detail_panel/list_field.gd")

@export var _style_path: NodePath
@onready var _style: TextField = self.get_node(self._style_path)
@export var _aliases_path: NodePath
@onready var _aliases: ListField = self.get_node(self._aliases_path)

func display(icon: IconFontAwesome) -> void:
    self._aliases.set_items(icon.aliases)
    self._style.text = icon.style
