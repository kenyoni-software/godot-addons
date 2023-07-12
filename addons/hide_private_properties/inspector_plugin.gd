extends EditorInspectorPlugin

var editor_interface: EditorInterface

func _can_handle(object: Object) -> bool:
    var scene_path: String = object.get("scene_file_path")
    return scene_path != null && scene_path != "" && object != self.editor_interface.get_edited_scene_root()

func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
    if name.begins_with("_"):
        return true
    return false
