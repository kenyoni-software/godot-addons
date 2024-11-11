extends Node

const Licenses := preload("res://addons/licenses/licenses.gd")
const Component := preload("res://addons/licenses/component.gd")

signal components_changed()
signal cfg_path_changed(new_path: String)

var _components: Array[Component] = []

func emit_components_changed() -> void:
    self.components_changed.emit()

func set_cfg_path(new_path: String) -> void:
    Licenses.set_license_data_filepath(new_path)
    self.cfg_path_changed.emit(new_path)

func add_component(component: Component) -> void:
    self._components.append(component)
    self._components.sort_custom(Licenses.compare_components_ascending)

func set_components(components_: Array[Component]) -> void:
    self._components = components_

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

static func create_interface() -> void:
    var li: Node = new()
    li.name = "kenyoni_licenses_interface"
    # EditorInterface.get_base_control() is not used to avoid dependency on Godot editor
    (Engine.get_main_loop() as SceneTree).get_root().add_child(li)

static func get_interface():
    return (Engine.get_main_loop() as SceneTree).get_root().get_node("kenyoni_licenses_interface")

static func remove_interface() -> void:
    (Engine.get_main_loop() as SceneTree).get_root().get_node("kenyoni_licenses_interface").queue_free()
