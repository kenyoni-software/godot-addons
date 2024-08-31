@tool
extends EditorPlugin

const ReloaderScene: PackedScene = preload("res://addons/kenyoni/plugin_reloader/internal/reloader.tscn")
const Reloader := preload("res://addons/kenyoni/plugin_reloader/internal/reloader.gd")

var _reloader: Reloader

func _get_plugin_name() -> String:
    return "Plugin Reloader"

func _enter_tree() -> void:
    self._reloader = ReloaderScene.instantiate()
    self.add_control_to_container(CustomControlContainer.CONTAINER_TOOLBAR, self._reloader)
    # move before editor run bar
    self._reloader.get_parent().move_child(self._reloader, self._reloader.get_parent().find_child("@EditorRunBar@*", true, false).get_index())

func _exit_tree() -> void:
    self.remove_control_from_container(CustomControlContainer.CONTAINER_TOOLBAR, self._reloader)
    self._reloader.queue_free()
