@tool
extends EditorPlugin

func _enter_tree() -> void:
    self.add_autoload_singleton("GLogging", self.get_script().get_path().get_base_dir() + "/glogging.gd")

func _exit_tree() -> void:
    self.remove_autoload_singleton("GLogging")
