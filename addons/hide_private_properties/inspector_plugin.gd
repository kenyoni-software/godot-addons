extends EditorInspectorPlugin

var hide_private_properties: bool = true

func _can_handle(object: Object) -> bool:
    # Early return if property does not exist, prevents triggering a warning for
    # some objects that overwrite the 'get' method.
    if !self.hide_private_properties || !self._has_property(object, "scene_file_path"):
        return false

    var scene_path: Variant = object.get("scene_file_path")
    return scene_path != null && scene_path != "" && object != EditorInterface.get_edited_scene_root()

func _parse_property(_object: Object, _type: Variant.Type, name: String, _hint_type: PropertyHint, _hint_string: String, _usage_flags: int, _wide: bool) -> bool:
    if name.begins_with("_"):
        return true
    return false

func _has_property(object: Object, propertyName: String) -> bool:
    # Note: Checking if the property exists using the 'in' keyword also triggers 
    # the warning in 'core/config/project_settings.cpp:_get' (v4.2.1)
    for property: Dictionary in object.get_property_list():
        if property.get("name", "") == propertyName:
            return true
    return false
