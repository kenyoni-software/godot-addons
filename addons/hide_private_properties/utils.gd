static func scan_path(path: String) -> Array[PackedStringArray]:
    var dir: DirAccess = DirAccess.open(path)
    if dir == null:
        push_error("[Hide Private Properties] Failed to open directory: ", path, " - ", DirAccess.get_open_error())
        return []
    var warnings: Array[PackedStringArray] = []
    var files: PackedStringArray = dir.get_files()
    for filename: String in files:
        if filename.ends_with(".res") || filename.ends_with(".scn") || filename.ends_with(".tscn"):
            var scene: PackedScene = load(path.path_join(filename))
            if scene != null:
                warnings.append_array(check_scene(scene))
    for sub_dir: String in dir.get_directories():
        warnings.append_array(scan_path(path.path_join(sub_dir)))
    return warnings

## returns Array[Array[String]]
## [scene path, node path, property name]
static func check_scene(scene: PackedScene) -> Array[PackedStringArray]:
    var warnings: Array[PackedStringArray] = []
    var state: SceneState = scene.get_state()
    for node_idx: int in range(state.get_node_count()):
        var private_properties: PackedStringArray = get_node_private_properties(state, node_idx)
        if private_properties.size() == 0:
            continue
        var node_scene: PackedScene = null
        if state.is_node_instance_placeholder(node_idx):
            node_scene = load(state.get_node_instance_placeholder(node_idx))
        else:
            node_scene = state.get_node_instance(node_idx)
        if node_scene == null:
            continue
        for private_prop: String in private_properties:
            var overridden_value: Variant = get_node_property_value(state, node_idx, private_prop)
            # check if the property is overridden by the instantiated scene
            # it is not enough to check for null as the property might be set to null
            if has_node_property_value(node_scene.get_state(), 0, private_prop):
                var default_value: Variant = get_node_property_value(node_scene.get_state(), 0, private_prop)
                if overridden_value != default_value:
                    warnings.push_back(PackedStringArray([scene.get_path(), state.get_node_path(node_idx), private_prop]))
                continue
            # as it is not overridden by the instantiated scene, we have to check the default value set by the script
            var script: Variant = get_node_property_value(node_scene.get_state(), 0, "script")
            if script != null && overridden_value != (script as Script).get_property_default_value(private_prop):
                warnings.push_back(PackedStringArray([scene.get_path(), state.get_node_path(node_idx), private_prop]))
    return warnings

static func has_node_property_value(state: SceneState, node_idx: int, prop_name: String) -> bool:
    for prop_idx: int in range(state.get_node_property_count(node_idx)):
        var name: String = state.get_node_property_name(node_idx, prop_idx)
        if name == prop_name:
            return true
    return false

static func get_node_property_value(state: SceneState, node_idx: int, prop_name: String) -> Variant:
    for prop_idx: int in range(state.get_node_property_count(node_idx)):
        var name: String = state.get_node_property_name(node_idx, prop_idx)
        if name == prop_name:
            return state.get_node_property_value(node_idx, prop_idx)
    return null

static func get_node_private_properties(state: SceneState, node_idx: int) -> PackedStringArray:
    var private_properties: PackedStringArray = []
    for prop_idx: int in range(state.get_node_property_count(node_idx)):
        var prop_name: String = state.get_node_property_name(node_idx, prop_idx)
        if prop_name.begins_with("_"):
            private_properties.push_back(prop_name)
    return private_properties
