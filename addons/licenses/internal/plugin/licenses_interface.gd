extends Node

const Licenses := preload("res://addons/licenses/licenses.gd")
const Component := preload("res://addons/licenses/component.gd")
const LicensesDialog := preload("res://addons/licenses/internal/licenses_dialog.gd")

signal components_changed()
signal cfg_path_changed(new_path: String)

var _licenses_dialog: LicensesDialog

var _components: Array[Component] = []

func _ready() -> void:
    self._licenses_dialog = load("res://addons/licenses/internal/licenses_dialog.tscn").instantiate()
    self.add_child(self._licenses_dialog)

func show_popup(show_comp: Component = null) -> void:
    if show_comp != null:
        self._licenses_dialog.show_component(show_comp)
    if self._licenses_dialog.visible:
        self._licenses_dialog.grab_focus()
    else:
        self._licenses_dialog.popup_centered_ratio(0.4)

func load_licenses(license_path: String) -> Licenses.LoadResult:
    var res: Licenses.LoadResult = Licenses.load(license_path)
    self._components = res.components
    self.sort_custom(Licenses.compare_components_ascending)
    self.emit_components_changed()
    return res

func emit_components_changed() -> void:
    self.components_changed.emit()

func set_cfg_path(new_path: String) -> void:
    Licenses.set_license_data_filepath(new_path)
    self.cfg_path_changed.emit(new_path)

func add_component(component: Component) -> void:
    self._components.append(component)
    self._components.sort_custom(Licenses.compare_components_ascending)

func components() -> Array[Component]:
    return self._components

func get_at(idx: int) -> Component:
    return self._components[idx]

func remove_at(idx: int) -> void:
    self._components.remove_at(idx)

func remove_component(component: Component) -> void:
    var idx: int = self._components.find(component)
    if idx == -1:
        return
    self.remove_at(idx)

func sort_custom(fn: Callable) -> void:
    self._components.sort_custom(fn)

func count() -> int:
    return len(self._components)

func get_components_in_path(path: String) -> Array[Component]:
    var res: Array[Component] = []
    for comp: Component in self._components:
        for idx: int in range(comp.paths.size()):
            if comp.paths[idx].begins_with(path):
                res.append(comp)
                break
    return res

static func create_interface() -> void:
    var li: Node = new()
    li.name = "kenyoni_license_manager_interface"
    # EditorInterface.get_base_control() is not used to avoid dependency on Godot editor
    (Engine.get_main_loop() as SceneTree).get_root().add_child(li)

static func get_interface():
    return (Engine.get_main_loop() as SceneTree).get_root().get_node("kenyoni_license_manager_interface")

static func remove_interface() -> void:
    (Engine.get_main_loop() as SceneTree).get_root().get_node("kenyoni_license_manager_interface").free()
