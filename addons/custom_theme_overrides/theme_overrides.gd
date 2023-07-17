extends RefCounted
class_name CustomThemeOverrides

var _overrides: Array[Item] = []

class Item:
    var name: StringName
    var type: Theme.DataType

    func _init(name: StringName, type: Theme.DataType) -> void:
        self.name = name
        self.type = type

func _init(overrides: Array[Array]) -> void:
    for item in overrides:
        self._overrides.append(Item.new(item[0], item[1]))

func theme_property_list(obj: Control) -> Array[Dictionary]:
    if len(self._overrides) == 0:
        return []

    var props: Array[Dictionary] = [{
        "name": "Theme Overrides",
        "type": TYPE_NIL,
        "usage": PROPERTY_USAGE_GROUP,
        "hint_string": "theme_override_"
    }]
    for item in self._overrides:
        var prop_prefix: String = ""
        var prop_type: Variant.Type
        var prop_hint: PropertyHint
        var prop_hint_string: String
        match item.type:
            Theme.DATA_TYPE_COLOR:
                prop_prefix = "theme_override_colors/"
                prop_type = TYPE_COLOR
            Theme.DATA_TYPE_CONSTANT:
                prop_prefix = "theme_override_constants/"
                prop_type = TYPE_INT
            Theme.DATA_TYPE_FONT:
                prop_prefix = "theme_override_fonts/"
                prop_type = TYPE_OBJECT
                prop_hint = PROPERTY_HINT_RESOURCE_TYPE
                prop_hint_string = "Font"
            Theme.DATA_TYPE_FONT_SIZE:
                prop_prefix = "theme_override_font_sizes/"
                prop_type = TYPE_INT
            Theme.DATA_TYPE_ICON:
                prop_prefix = "theme_override_icons/"
                prop_type = TYPE_OBJECT
                prop_hint = PROPERTY_HINT_RESOURCE_TYPE
                prop_hint_string = "Texture2D"
            Theme.DATA_TYPE_STYLEBOX:
                prop_prefix = "theme_override_styles/"
                prop_type = Variant.Type.TYPE_OBJECT
                prop_hint = PROPERTY_HINT_RESOURCE_TYPE
                prop_hint_string = "StyleBox"

        var usage: int = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_CHECKABLE
        if obj.get(prop_prefix + item.name) != null:
            usage = usage | PROPERTY_USAGE_STORAGE
        props.append({
            "name": prop_prefix + item.name,
            "type": prop_type,
            "usage": usage,
            "hint": prop_hint,
            "hint_string": prop_hint_string
        })
    return props

func can_revert(prop_name: StringName) -> bool:
    for item in self._overrides:
        if item.name == prop_name:
            return true
    return false
