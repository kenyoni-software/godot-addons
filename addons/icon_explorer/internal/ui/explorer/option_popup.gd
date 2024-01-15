@tool
extends Window

func _notification(what: int) -> void:
    if (what == NOTIFICATION_WM_CLOSE_REQUEST):
        self.hide()
