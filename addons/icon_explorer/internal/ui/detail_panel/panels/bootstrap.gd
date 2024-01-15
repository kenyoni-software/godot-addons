@tool
extends VBoxContainer

const IconBootstrap := preload("res://addons/icon_explorer/internal/scripts/collections/icon_bootstrap.gd")
const TextField := preload("res://addons/icon_explorer/internal/ui/detail_panel/text_field.gd")
const ListField := preload("res://addons/icon_explorer/internal/ui/detail_panel/list_field.gd")

@export var _categories_path: NodePath
@onready var _categories: ListField = self.get_node(self._categories_path)
@export var _tags_path: NodePath
@onready var _tags: ListField = self.get_node(self._tags_path)
@export var _version_added_path: NodePath
@onready var _version_added: TextField = self.get_node(self._version_added_path)

func display(icon: IconBootstrap) -> void:
    self._categories.set_items(icon.categories)
    self._tags.set_items(icon.tags)
    self._version_added.text = icon.version_added
