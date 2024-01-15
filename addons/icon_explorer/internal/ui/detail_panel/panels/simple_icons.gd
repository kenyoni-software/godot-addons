@tool
extends VBoxContainer

const IconSimpleIcons := preload("res://addons/icon_explorer/internal/scripts/collections/icon_simple_icons.gd")
const ColorField := preload("res://addons/icon_explorer/internal/ui/detail_panel/color_field.gd")
const TextField := preload("res://addons/icon_explorer/internal/ui/detail_panel/text_field.gd")
const ListField := preload("res://addons/icon_explorer/internal/ui/detail_panel/list_field.gd")

@export var _color_path: NodePath
@onready var _color: ColorField = self.get_node(self._color_path)
@export var _aliases_path: NodePath
@onready var _aliases: ListField = self.get_node(self._aliases_path)
@export var _guidelines_path: NodePath
@onready var _guidelines: TextField = self.get_node(self._guidelines_path)
@export var _license_path: NodePath
@onready var _license: TextField = self.get_node(self._license_path)
@export var _source_path: NodePath
@onready var _source: TextField = self.get_node(self._source_path)

func display(icon: IconSimpleIcons) -> void:
    self._color.color = icon.hex
    self._aliases.set_items(icon.aliases)
    self._guidelines.text = icon.guidelines
    self._guidelines.uri = icon.guidelines
    self._license.text = icon.license
    self._license.uri = icon.license_link
    self._source.text = icon.source
    self._source.uri = icon.source
