@tool
extends VBoxContainer

const IconFontAwesome := preload("res://addons/icon_explorer/internal/ext/font_awesome/icon.gd")
const TextField := preload("res://addons/icon_explorer/internal/ui/detail_panel/text_field.gd")
const ListField := preload("res://addons/icon_explorer/internal/ui/detail_panel/list_field.gd")

@export var _style: TextField
@export var _aliases: ListField

func display(icon: IconFontAwesome) -> void:
    self._aliases.set_items(icon.aliases)
    self._style.text = icon.style
