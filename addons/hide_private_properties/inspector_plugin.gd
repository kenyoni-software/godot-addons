extends EditorInspectorPlugin

func _can_handle(object: Object) -> bool:
    # Early return if property does not exist, prevents triggering a warning for
    # some objects that overwrite the 'get' method.
    if not _has_property(object, "scene_file_path"):
        return false
    
    var scene_path: Variant = object.get("scene_file_path")
    return scene_path != null && scene_path != "" && object != EditorInterface.get_edited_scene_root()

func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
    if name.begins_with("_"):
        return true
    return false

func _has_property(object: Object, propertyName: String) -> bool:
    # Note: Checking if the property exists using the 'in' keyword also triggers 
    # the warning in 'core/config/project_settings.cpp:_get' (v4.2.1)
    for property: Dictionary in object.get_property_list():
        if property.name == propertyName:
            return true
    return false
