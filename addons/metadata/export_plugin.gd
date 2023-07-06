extends EditorExportPlugin

const Utils := preload("utils.gd")

func _get_name() -> Strinig:
    return "kenyoni_metadata_exporter"

func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
    Utils.update_git_sha()

func _export_end() -> void:
    ProjectSettings.set_setting(Utils.GIT_SHA_PATH, null)
