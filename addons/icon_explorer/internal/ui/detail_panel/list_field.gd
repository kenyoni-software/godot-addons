@tool
extends "res://addons/icon_explorer/internal/ui/detail_panel/field.gd"

@export var items: PackedStringArray = []:
    set = set_items

@export var _list: ItemList

func set_items(new_items: PackedStringArray) -> void:
    items = new_items
    if self._list != null:
        self._list.clear()
        for item: String in new_items:
            self._list.add_item(item)
        self.visible = new_items.size() > 0

func _ready() -> void:
    super._ready()
    self.items = self.items
