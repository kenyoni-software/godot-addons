extends RefCounted

const LicensesInterface := preload("res://addons/licenses/internal/plugin/licenses_interface.gd")
const Component := preload("res://addons/licenses/component.gd")
const Licenses := preload("res://addons/licenses/licenses.gd")

var _li: LicensesInterface

func _init():
    self._li = LicensesInterface.get_interface()
    var fs_dock: FileSystemDock = EditorInterface.get_file_system_dock()
    fs_dock.files_moved.connect(self._on_file_moved)
    fs_dock.folder_moved.connect(self._on_folder_moved)

func _on_file_moved(old_file: String, new_file: String) -> void:
    if old_file == Licenses.get_license_data_filepath():
        self._li.set_cfg_path(new_file)
        return

    var changed: bool = false
    for comp: Component in self._li.components():
        for idx: int in range(comp.paths.size()):
            if comp.paths[idx] == old_file:
                changed = true
                comp.paths[idx] = new_file
        for license: Component.License in comp.licenses:
            if license.file == old_file:
                changed = true
                license.file = new_file
    if changed:
        self._li.emit_components_changed()


func _on_folder_moved(old_folder: String, new_folder: String) -> void:
    var old_folder_no_slash: String = old_folder.rstrip("/")
    # check cfg file
    var cfg_file: String = Licenses.get_license_data_filepath()
    if cfg_file.begins_with(old_folder):
        self._li.set_cfg_path(new_folder.rstrip("/") + "/" + cfg_file.trim_prefix(old_folder))

    var changed: bool = false
    for comp: Component in self._li.components():
        for idx: int in range(comp.paths.size()):
            var path: String = comp.paths[idx]
            if path == old_folder_no_slash:
                changed = true
                comp.paths[idx] = new_folder.rstrip("/")
            if path.begins_with(old_folder):
                changed = true
                comp.paths[idx] = new_folder.rstrip("/") + "/" + comp.paths[idx].trim_prefix(old_folder)
        for license: Component.License in comp.licenses:
            if license.file.begins_with(old_folder):
                changed = true
                license.file = new_folder.rstrip("/") + "/" + license.file.trim_prefix(old_folder)
    if changed:
        self._li.emit_components_changed()
