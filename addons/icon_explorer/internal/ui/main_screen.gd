@tool
extends Control

const Explorer := preload("res://addons/icon_explorer/internal/ui/explorer/explorer.gd")
const IconDatabase := preload("res://addons/icon_explorer/internal/scripts/database.gd")

@export var _explorer: Explorer

func _ready() -> void:
    self.focus_entered.connect(self._on_focus_entered)

func set_icon_db(db: IconDatabase) -> void:
    self._explorer.set_icon_db(db)

func _on_focus_entered() -> void:
    self._explorer.grab_focus()
