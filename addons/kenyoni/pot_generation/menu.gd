@tool
extends VBoxContainer

const PotTree := preload("res://addons/kenyoni/pot_generation/tree.gd")
const Utils := preload("res://addons/kenyoni/pot_generation/utils.gd")

@export var _tree: PotTree
@export var _add_dir: Button
@export var _add_files: Button
@export var _generate_pot: Button
@export var _add_built_in_strings: CheckBox
@export var _show_filtered_files: CheckBox

var _dir_dialog: EditorFileDialog = EditorFileDialog.new()
var _file_dialog: EditorFileDialog = EditorFileDialog.new()

func _ready() -> void:
    self.add_child(self._dir_dialog)
    self._dir_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
    self._dir_dialog.dialog_hide_on_ok = true
    self.add_child(self._file_dialog)
    self._file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILES
    self._file_dialog.dialog_hide_on_ok = true
    self._file_dialog.filters = ["*.gd", "*.tscn", "*.scn", "*.tres", "*.res"]

    var paths: Array[PackedStringArray] = ProjectSettings.get_setting("plugins/kenyoni/pot_generation/paths", [])
    for path: PackedStringArray in paths:
        self._tree.add_gen_item(path[0], path[1])

    self._dir_dialog.dir_selected.connect(self._on_dir_selected)
    self._file_dialog.files_selected.connect(self._on_files_selected)
    self._add_dir.pressed.connect(self._dir_dialog.popup_centered_ratio.bind(0.4))
    self._add_files.pressed.connect(self._file_dialog.popup_centered_ratio.bind(0.4))
    self._generate_pot.pressed.connect(self._on_generate_pot_pressed)
    self._add_built_in_strings.toggled.connect(Utils.add_built_in_strings_to_pot)
    self._show_filtered_files.toggled.connect(self._on_show_filtered_files_toggled)
    self._tree.paths_changed.connect(self._on_paths_changed)
    ProjectSettings.settings_changed.connect(self._on_settings_changed)

func _gen_filtered_files() -> PackedStringArray:
    var paths: Array[PackedStringArray] = ProjectSettings.get_setting("plugins/kenyoni/pot_generation/paths", [])
    var files: PackedStringArray = []
    for path: PackedStringArray in paths:
        var base_path: String = path[0]
        var filter: PackedStringArray = Utils.get_filter_from_string(path[1])
        var cur_files: PackedStringArray = Utils.get_filtered_files(base_path, filter)
        for file: String in cur_files:
            if !files.has(file):
                files.push_back(file)
    ProjectSettings.set_setting("internationalization/locale/translations_pot_files", files)
    var err: Error = ProjectSettings.save()
    if err != Error.OK:
        push_error("[POT Generation] Failed to save project settings: " + error_string(err))
    return files

func _on_generate_pot_pressed() -> void:
    self._gen_filtered_files()
    Utils.gen_pot_files()

func _on_dir_selected(path: String) -> void:
    self._tree.add_gen_item(path + "/", "*")

func _on_files_selected(files: PackedStringArray) -> void:
    for file: String in files:
        self._tree.add_gen_item(file, "")

func _on_show_filtered_files_toggled(toggled: bool) -> void:
    self._tree.show_filtered_files = toggled

func _on_paths_changed(paths: Array[PackedStringArray]) -> void:
    ProjectSettings.set_setting("plugins/kenyoni/pot_generation/paths", paths)
    var err: Error = ProjectSettings.save()
    if err != Error.OK:
        push_error("[POT Generation] Failed to save project settings: " + error_string(err))
    self._gen_filtered_files()

func _on_settings_changed() -> void:
    self._add_built_in_strings.set_pressed_no_signal(ProjectSettings.get_setting("internationalization/locale/translation_add_builtin_strings_to_pot", false))
