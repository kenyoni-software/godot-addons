extends RefCounted
class_name CustomThemeOverrides

var _overrides: Array[Item] = []

class Item:
    var name: StringName
    var type: Theme.DataType

    func _init(name: StringName, type: Theme.DataType) -> void:
        self.name = name
        self.type = type

    func full_name() -> String:
        match self.type:
            Theme.DATA_TYPE_COLOR:
                return "theme_override_colors/" + self.name
            Theme.DATA_TYPE_CONSTANT:
                return "theme_override_constants/" + self.name
            Theme.DATA_TYPE_FONT:
                return "theme_override_fonts/" + self.name
            Theme.DATA_TYPE_FONT_SIZE:
                return "theme_override_font_sizes/" + self.name
            Theme.DATA_TYPE_ICON:
                return "theme_override_icons/" + self.name
            Theme.DATA_TYPE_STYLEBOX:
                return "theme_override_styles/" + self.name
        return self.name

func _init(overrides: Array[Array]) -> void:
    for item: Array in overrides:
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
    for item: Item in self._overrides:
        var prop_type: Variant.Type
        var prop_hint: PropertyHint
        var prop_hint_string: String
        match item.type:
            Theme.DATA_TYPE_COLOR:
                prop_type = TYPE_COLOR
            Theme.DATA_TYPE_CONSTANT:
                prop_type = TYPE_INT
            Theme.DATA_TYPE_FONT:
                prop_type = TYPE_OBJECT
                prop_hint = PROPERTY_HINT_RESOURCE_TYPE
                prop_hint_string = "Font"
            Theme.DATA_TYPE_FONT_SIZE:
                prop_type = TYPE_INT
            Theme.DATA_TYPE_ICON:
                prop_type = TYPE_OBJECT
                prop_hint = PROPERTY_HINT_RESOURCE_TYPE
                prop_hint_string = "Texture2D"
            Theme.DATA_TYPE_STYLEBOX:
                prop_type = Variant.Type.TYPE_OBJECT
                prop_hint = PROPERTY_HINT_RESOURCE_TYPE
                prop_hint_string = "StyleBox"

        var full_name: String = item.full_name()
        var usage: int = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_CHECKABLE
        if obj.get(full_name) != null:
            usage = usage | PROPERTY_USAGE_STORAGE
        props.append({
            "name": full_name,
            "type": prop_type,
            "usage": usage,
            "hint": prop_hint,
            "hint_string": prop_hint_string
        })
    return props

func can_revert(prop_name: StringName) -> bool:
    for item: Item in self._overrides:
        if item.full_name() == prop_name:
            return true
    return false
