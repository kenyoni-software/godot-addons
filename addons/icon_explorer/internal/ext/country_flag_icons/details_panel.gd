@tool
extends VBoxContainer

const IconCountryFlags := preload("res://addons/icon_explorer/internal/ext/country_flag_icons/icon.gd")
const TextField := preload("res://addons/icon_explorer/internal/ui/detail_panel/text_field.gd")
const ListField := preload("res://addons/icon_explorer/internal/ui/detail_panel/list_field.gd")

@export var _country_code: TextField

func display(icon: IconCountryFlags) -> void:
    self._country_code.text = icon.country_code
