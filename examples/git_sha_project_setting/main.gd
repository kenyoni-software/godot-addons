extends PanelContainer

@export var _version: Label
@export var _git_sha: Label
@export var _version_complete: Label

func _ready() -> void:
    var version: String = ProjectSettings.get_setting("application/config/version", "<not set>")
    var git_sha: String = ProjectSettings.get_setting("application/config/git_sha", "<unavailable>")
    self._version.text = version
    self._git_sha.text = git_sha
    self._version_complete.text = version + "-" + git_sha.substr(0, 6)
