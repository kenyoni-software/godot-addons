@tool
extends VBoxContainer

const IconTabler := preload("res://addons/icon_explorer/internal/scripts/collections/icon_tabler.gd")
const TextField := preload("res://addons/icon_explorer/internal/ui/detail_panel/text_field.gd")
const ListField := preload("res://addons/icon_explorer/internal/ui/detail_panel/list_field.gd")

@export var _category_path: NodePath
@onready var _category: TextField = self.get_node(self._category_path)
@export var _tags_path: NodePath
@onready var _tags: ListField = self.get_node(self._tags_path)
@export var _version_path: NodePath
@onready var _version: TextField = self.get_node(self._version_path)

func display(icon: IconTabler) -> void:
    self._tags.set_items(icon.tags)
    self._category.text = icon.category
    self._version.text = icon.version
