@tool
extends EditorPlugin

func _enable_plugin() -> void:
    self.add_autoload_singleton("GLogging", (self.get_script() as Script).get_path().get_base_dir().path_join("glogging.gd"))

func _disable_plugin() -> void:
    self.remove_autoload_singleton("GLogging")
