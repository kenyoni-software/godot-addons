@tool
extends VBoxContainer

const IconTabler := preload("res://addons/icon_explorer/internal/ext/icon_tabler/icon.gd")
const TextField := preload("res://addons/icon_explorer/internal/ui/detail_panel/text_field.gd")
const ListField := preload("res://addons/icon_explorer/internal/ui/detail_panel/list_field.gd")

@export var _category: TextField
@export var _tags: ListField
@export var _version: TextField

func display(icon: IconTabler) -> void:
    self._tags.set_items(icon.tags)
    self._category.text = icon.category
    self._version.text = icon.version
