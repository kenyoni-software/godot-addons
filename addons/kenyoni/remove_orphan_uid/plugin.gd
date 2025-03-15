@tool
extends EditorPlugin

func _enter_tree() -> void:
    self.add_tool_menu_item("Remove Orphan UIDs", self._on_menu_pressed)

func _exit_tree() -> void:
    self.remove_tool_menu_item("Remove Orphan UIDs")

func _on_menu_pressed() -> void:
    var counter: int = self._remove_orphan_uid("res://")
    if counter > 0:
        EditorInterface.get_editor_toaster().push_toast("[Remove Orphan UID] Removed " + str(counter) + " orphan UID files.", EditorToaster.SEVERITY_INFO)
    else:
        EditorInterface.get_editor_toaster().push_toast("[Remove Orphan UID] No orphan UID files found.", EditorToaster.SEVERITY_INFO)

func _remove_orphan_uid(path: String) -> int:
    var dir: DirAccess = DirAccess.open(path)
    if dir == null:
        push_error("[Remove Orphan UID] Failed to open directory: ", path, " - ", DirAccess.get_open_error())
        return 0

    var counter: int = 0
    var files: PackedStringArray = dir.get_files()
    for file: String in files:
        if file.ends_with(".uid") && !files.has(file.substr(0, file.length() - 4)):
            var err: Error = DirAccess.remove_absolute(path.path_join(file))
            if err == OK:
                counter += 1
                print("[Remove Orphan UID] Removed: ", path.path_join(file))
            else:
                push_error("[Remove Orphan UID] Failed to remove: ", path.path_join(file), " - ", error_string(err))
    for sub_dir: String in dir.get_directories():
        counter += self._remove_orphan_uid(path.path_join(sub_dir))
    return counter
