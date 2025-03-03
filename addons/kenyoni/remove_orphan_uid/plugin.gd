@tool
extends EditorPlugin

func _enter_tree() -> void:
    self.add_tool_menu_item("Remove Orphan UIDs", self._remove_orphan_uid.bind("res://"))

func _exit_tree() -> void:
    self.remove_tool_menu_item("Remove Orphan UIDs")

func _remove_orphan_uid(path: String) -> void:
    var dir: DirAccess = DirAccess.open(path)
    if dir == null:
        push_error("[Remove Orphan UID] Failed to open directory: ", path, " - ", DirAccess.get_open_error())
        return

    var files: PackedStringArray = dir.get_files()
    for file: String in files:
        if file.ends_with(".uid") && !files.has(file.substr(0, file.length() - 4)):
            var err: Error = DirAccess.remove_absolute(path.path_join(file))
            if err != OK:
                push_error("[Remove Orphan UID] Failed to remove: ", path.path_join(file), " - ", error_string(err))
            else:
                print("[Remove Orphan UID] Removed: ", path.path_join(file))
    for sub_dir: String in dir.get_directories():
        self._remove_orphan_uid(path.path_join(sub_dir))
