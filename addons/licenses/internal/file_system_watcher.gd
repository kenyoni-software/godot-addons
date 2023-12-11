extends RefCounted

const ComponentsContainer := preload("components_container.gd")

var _components: ComponentsContainer

func _init(components: ComponentsContainer):
    self._components = components
    var fs_dock: FileSystemDock = EditorInterface.get_file_system_dock()
    fs_dock.files_moved.connect(self._on_file_moved)
    fs_dock.folder_moved.connect(self._on_folder_moved)

func _on_file_moved(old_file: String, new_file: String) -> void:
    var changed: bool = false
    for comp in self._components.components():
        for idx in range(comp.paths.size()):
            var path: String = comp.paths[idx]
            if path == old_file:
                changed = true
                comp.paths[idx] = new_file
    if changed:
        self._components.emit_changed()

func _on_folder_moved(old_folder: String, new_folder: String) -> void:
    var old_folder_no_slash: String = old_folder.rstrip("/")
    var changed: bool = false
    for comp in self._components.components():
        for idx in range(comp.paths.size()):
            var path: String = comp.paths[idx]
            if path == old_folder_no_slash:
                changed = true
                comp.paths[idx] = new_folder.rstrip("/")
            if path.begins_with(old_folder):
                comp.paths[idx] = new_folder.rstrip("/") + "/" + comp.paths[idx].trim_prefix(old_folder)
    if changed:
        self._components.emit_changed()
