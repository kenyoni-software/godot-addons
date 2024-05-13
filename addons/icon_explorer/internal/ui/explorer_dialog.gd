@tool
extends Window

const Explorer := preload("res://addons/icon_explorer/internal/ui/explorer/explorer.gd")
const IconDatabase := preload("res://addons/icon_explorer/internal/scripts/database.gd")

@export var _explorer: Explorer

var _db: IconDatabase
var _db_loaded: bool = false

func set_icon_db(db: IconDatabase) -> void:
    self._db = db
    self._explorer.set_icon_db(db)

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        self.hide()

func _on_about_to_popup() -> void:
    if !self._db_loaded:
        self._db_loaded = true
        self._db.load()
    self._explorer.grab_focus()
