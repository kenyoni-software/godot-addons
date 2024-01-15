extends Node

const Component := preload("res://addons/licenses/component.gd")
const Licenses := preload("res://addons/licenses/licenses.gd")

signal components_changed()

var _components: Array[Component] = []

func emit_changed() -> void:
    self.components_changed.emit()

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
