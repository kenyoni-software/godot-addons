@tool
extends VBoxContainer

const IconMaterialDesign := preload("res://addons/icon_explorer/internal/ext/material_design/icon.gd")
const TextField := preload("res://addons/icon_explorer/internal/ui/detail_panel/text_field.gd")
const ListField := preload("res://addons/icon_explorer/internal/ui/detail_panel/list_field.gd")

@export var _deprecated_banner: Label
@export var _aliases: ListField
@export var _tags: ListField
@export var _author: TextField
@export var _version: TextField

func display(icon: IconMaterialDesign) -> void:
    self._deprecated_banner.visible = icon.deprecated
    self._aliases.set_items(icon.aliases)
    self._tags.set_items(icon.tags)
    self._author.text = icon.author
    self._version.text = icon.version
