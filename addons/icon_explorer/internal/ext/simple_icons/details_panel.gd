@tool
extends VBoxContainer

const IconSimpleIcons := preload("res://addons/icon_explorer/internal/ext/simple_icons/icon.gd")
const ColorField := preload("res://addons/icon_explorer/internal/ui/detail_panel/color_field.gd")
const TextField := preload("res://addons/icon_explorer/internal/ui/detail_panel/text_field.gd")
const ListField := preload("res://addons/icon_explorer/internal/ui/detail_panel/list_field.gd")

@export var _color: ColorField
@export var _aliases: ListField
@export var _guidelines: TextField
@export var _license: TextField
@export var _source: TextField

func display(icon: IconSimpleIcons) -> void:
    self._color.color = icon.hex
    self._aliases.set_items(icon.aliases)
    self._guidelines.text = icon.guidelines
    self._guidelines.uri = icon.guidelines
    self._license.text = icon.license
    self._license.uri = icon.license_link
    self._source.text = icon.source
    self._source.uri = icon.source
