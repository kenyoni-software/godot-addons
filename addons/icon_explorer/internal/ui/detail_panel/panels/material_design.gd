@tool
extends VBoxContainer

const IconMaterialDesign := preload("res://addons/icon_explorer/internal/scripts/collections/icon_material_design.gd")
const TextField := preload("res://addons/icon_explorer/internal/ui/detail_panel/text_field.gd")
const ListField := preload("res://addons/icon_explorer/internal/ui/detail_panel/list_field.gd")

@export var _deprecated_banner: Label
@export var _aliases_path: NodePath
@onready var _aliases: ListField = self.get_node(self._aliases_path)
@export var _tags_path: NodePath
@onready var _tags: ListField = self.get_node(self._tags_path)
@export var _author_path: NodePath
@onready var _author: TextField = self.get_node(self._author_path)
@export var _version_path: NodePath
@onready var _version: TextField = self.get_node(self._version_path)

func display(icon: IconMaterialDesign) -> void:
    self._deprecated_banner.visible = icon.deprecated
    self._aliases.set_items(icon.aliases)
    self._tags.set_items(icon.tags)
    self._author.text = icon.author
    self._version.text = icon.version
