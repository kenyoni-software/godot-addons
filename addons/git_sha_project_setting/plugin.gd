@tool
extends EditorPlugin

const ExportPlugin := preload("res://addons/git_sha_project_setting/export_plugin.gd")
const Utils := preload("res://addons/git_sha_project_setting/utils.gd")

var export_plugin: ExportPlugin

func _disable_plugin() -> void:
    ProjectSettings.set_setting(Utils.GIT_SHA_PATH, null)
    ProjectSettings.save()

func _enter_tree() -> void:
    Utils.init_project_setting(Utils.GIT_SHA_PATH, "", TYPE_STRING, PROPERTY_HINT_NONE)
    ProjectSettings.set_as_internal(Utils.GIT_SHA_PATH, true)
    ProjectSettings.save()

    self.export_plugin = ExportPlugin.new()
    self.add_export_plugin(self.export_plugin)

    Utils.update_git_sha()
    ProjectSettings.save()

func _exit_tree() -> void:
    self.remove_export_plugin(self.export_plugin)
    ProjectSettings.set_setting(Utils.GIT_SHA_PATH, null)
    ProjectSettings.save()

func _build() -> bool:
    Utils.update_git_sha()
    ProjectSettings.save()
    return true
