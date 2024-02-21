enum Severity {
    INFO = 0,
    WARNING = 1,
    ERROR = 2
}

static var _editor_toaster: Node

static func do(node: Node) -> void:
    if node == null:
        print("null")
        return
    var parent = node.get_parent()
    while parent != null:
        print(parent.name)
        parent = parent.get_parent()

static func _get_editor_toaster() -> Node:
    var tmp_plugin: EditorPlugin = EditorPlugin.new()
    var tmp_ctrl: Control = Control.new()
    tmp_plugin.add_control_to_bottom_panel(tmp_ctrl, "tmp_ctrl")
    var toaster: Node = tmp_ctrl.get_parent().find_child("*EditorToaster*", true, false)
    tmp_plugin.remove_control_from_bottom_panel(tmp_ctrl)
    tmp_ctrl.queue_free()
    return toaster

static func notify(message: String, severity: Severity = Severity.INFO, tooltip: String = "") -> void:
    if _editor_toaster == null:
        _editor_toaster = _get_editor_toaster()
    if not is_instance_valid(_editor_toaster):
        return

    _editor_toaster.call("_popup_str", message, severity, tooltip)
