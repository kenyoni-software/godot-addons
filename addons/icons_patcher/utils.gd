const MDI_DIRECTORY_PATH: String = "plugins/icons_patcher/material_design_directory"

static func init_project_setting(key: String, default_value: Variant, type: int, type_hint: int) -> void:
    if not ProjectSettings.has_setting(key):
        ProjectSettings.set_setting(key, default_value)
    ProjectSettings.set_initial_value(key, default_value)
    ProjectSettings.add_property_info({
        "name": key,
        "type": type,
        "hint": type_hint,
    })

static func patch_icon_dir(dir_path: String, rx: RegEx, replacement: String) -> void:
    var dir: DirAccess = DirAccess.open(dir_path)
    if dir == null:
        push_error("Could not access path: '%s' - %d" % [dir_path, DirAccess.get_open_error()])
        return

    dir.list_dir_begin()
    var elem: String = dir.get_next()
    while (not elem.is_empty()):
        if dir.current_is_dir():
            patch_icon_dir(dir_path + "/" + elem, rx, replacement)
        elif elem.get_extension() == "svg":
            patch_icon(dir_path + "/" + elem, rx, replacement)
        elem = dir.get_next()
    dir.list_dir_end()
    dir = null

static func patch_icon(filepath: String, rx: RegEx, replacement: String) -> void:
    var file: FileAccess = FileAccess.open(filepath, FileAccess.READ_WRITE)
    if file == null:
        push_error("Could not patch file: '%s' - '%d'" % [filepath, FileAccess.get_open_error()])
        return
    var content: String = rx.sub(file.get_as_text(), replacement)

    file.store_string(content)
    file = null
