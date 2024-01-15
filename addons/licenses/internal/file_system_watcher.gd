extends RefCounted

const ComponentsContainer := preload("res://addons/licenses/internal/components_container.gd")
const Component := preload("res://addons/licenses/component.gd")

var _components: ComponentsContainer

func _init(components: ComponentsContainer):
    self._components = components
    var fs_dock: FileSystemDock = EditorInterface.get_file_system_dock()
    fs_dock.files_moved.connect(self._on_file_moved)
    fs_dock.folder_moved.connect(self._on_folder_moved)

func _on_file_moved(old_file: String, new_file: String) -> void:
    var changed: bool = false
    for comp: Component in self._components.components():
        for idx: int in range(comp.paths.size()):
            if comp.paths[idx] == old_file:
                changed = true
                comp.paths[idx] = new_file
        for license: Component.License in comp.licenses:
            if license.file == old_file:
                changed = true
                license.file = new_file
    if changed:
        self._components.emit_changed()

func _on_folder_moved(old_folder: String, new_folder: String) -> void:
    var old_folder_no_slash: String = old_folder.rstrip("/")
    var changed: bool = false
    for comp: Component in self._components.components():
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
        self._components.emit_changed()
