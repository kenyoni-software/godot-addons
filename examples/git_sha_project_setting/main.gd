extends PanelContainer

@export_node_path("Label") var _version_path; @onready var _version: Label = self.get_node(_version_path)
@export_node_path("Label") var _git_sha_path; @onready var _git_sha: Label = self.get_node(_git_sha_path)
@export_node_path("Label") var _version_complete_path; @onready var _version_complete: Label = self.get_node(_version_complete_path)

func _ready() -> void:
    var version: String = ProjectSettings.get_setting("application/config/version", "<not set>")
    var git_sha: String = ProjectSettings.get_setting("application/config/git_sha", "<unavailable>")
    self._version.text = version
    self._git_sha.text = git_sha
    self._version_complete.text = version + "-" + git_sha.substr(0, 6)
