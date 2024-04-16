@tool
extends VBoxContainer

const IconBootstrap := preload("res://addons/icon_explorer/internal/ext/bootstrap/icon.gd")
const TextField := preload("res://addons/icon_explorer/internal/ui/detail_panel/text_field.gd")
const ListField := preload("res://addons/icon_explorer/internal/ui/detail_panel/list_field.gd")

@export var _categories: ListField
@export var _tags: ListField
@export var _version_added: TextField

func display(icon: IconBootstrap) -> void:
    self._categories.set_items(icon.categories)
    self._tags.set_items(icon.tags)
    self._version_added.text = icon.version_added
