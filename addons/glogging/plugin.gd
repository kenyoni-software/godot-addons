@tool
extends EditorPlugin

func _enable_plugin() -> void:
    self.add_autoload_singleton("GLogging", self.get_script().get_path().get_base_dir() + "/glogging.gd")

func _disable_plugin() -> void:
    self.remove_autoload_singleton("GLogging")
