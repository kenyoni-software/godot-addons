@tool
extends EditorPlugin

const InspectorPlugin := preload("inspector_plugin.gd")

var _inspector_plugin: InspectorPlugin

func _enter_tree() -> void:
    self._inspector_plugin = InspectorPlugin.new()
    self.add_inspector_plugin(self._inspector_plugin)

func _exit_tree() -> void:
    self.remove_inspector_plugin(self._inspector_plugin)
