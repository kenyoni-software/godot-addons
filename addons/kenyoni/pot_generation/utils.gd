static var _pot_gen_button: Button
static var _add_built_in_strings_checkbox: CheckBox

## this function has to be called manually
static func _init() -> void:
    var proj_settings: Node = EditorInterface.get_base_control().find_child("*ProjectSettingsEditor*", true, false)
    var localization: Control = proj_settings.get_child(0).get_child(2)
    var pot_gen: Control = localization.get_child(0).get_child(2)
    _pot_gen_button = pot_gen.get_child(0).get_child(3)
    _add_built_in_strings_checkbox = pot_gen.get_child(2)

static func gen_pot_files() -> void:
    _pot_gen_button.pressed.emit()

static func add_built_in_strings_to_pot(enable: bool) -> void:
    ProjectSettings.set_setting("internationalization/locale/translation_add_builtin_strings_to_pot", enable)
    var err: Error = ProjectSettings.save()
    if err != Error.OK:
        push_error("[POT Generation] Failed to save project settings: " + error_string(err))
        return
    _add_built_in_strings_checkbox.set_pressed_no_signal(enable)

static func get_filtered_files(base_path: String, filter: PackedStringArray, sub_dir_path: String = "") -> PackedStringArray:
    if !base_path.ends_with("/"):
        return [base_path]
    var dir: DirAccess = DirAccess.open(base_path.path_join(sub_dir_path))
    if dir == null:
        push_error("[POT Generation] Failed to open directory: " + error_string(DirAccess.get_open_error()))
        return []
    var err: Error = dir.list_dir_begin()
    if err != OK:
        push_error("[POT Generation] Failed to list directory: " + error_string(err))
        return []
    var filtered_files: PackedStringArray = []
    var file_name: String = dir.get_next()
    while file_name != "":
        if dir.current_is_dir():
            filtered_files.append_array(get_filtered_files(base_path, filter, sub_dir_path.path_join(file_name)))
            file_name = dir.get_next()
            continue
        var file_path: String = base_path.path_join(sub_dir_path).path_join(file_name)
        if match_filter(file_path, filter):
            filtered_files.push_back(file_path)
        file_name = dir.get_next()
    dir.list_dir_end()
    dir = null

    return filtered_files

static func get_filter_from_string(filter_text: String) -> PackedStringArray:
    const split_char: String = ","
    var filters: PackedStringArray = []
    var start_idx: int = 0
    var end_idx: int = filter_text.find(split_char)
    while end_idx != -1:
        # ignore escaped commas
        if end_idx != 0 && filter_text[end_idx - 1] == "\\":
            end_idx = filter_text.find(split_char, end_idx + 1)
            continue 
        filters.push_back(filter_text.substr(start_idx, end_idx - start_idx))
        start_idx = end_idx + 1
        end_idx = filter_text.find(split_char, start_idx)
    filters.push_back(filter_text.substr(start_idx))
    return filters

static func match_filter(file_path: String, filters: PackedStringArray) -> bool:
    for filter: String in filters:
        if file_path.match(filter):
            return true
    return false
