@tool
extends GridContainer

# DO NOT
# - use @export
# - use setter and getter, they are NOT called in the editor
var my_font_color: Color
var my_border_size: int
var my_font: Font
var my_font_size: int
var my_icon: Texture2D
var my_style_box: StyleBox

var _theme_overrides = CustomThemeOverrides.new([
    ["my_font_color", Theme.DATA_TYPE_COLOR],
    ["my_border_size", Theme.DATA_TYPE_CONSTANT],
    ["my_font", Theme.DATA_TYPE_FONT],
    ["my_font_size", Theme.DATA_TYPE_FONT_SIZE],
    ["my_icon", Theme.DATA_TYPE_ICON],
    ["my_style_box", Theme.DATA_TYPE_STYLEBOX]
])

# required
func _get_property_list() -> Array[Dictionary]:
    return self._theme_overrides.theme_property_list(self)

# optional: if you want to use the revert function
func _property_can_revert(property: StringName) -> bool:
    return self._theme_overrides.can_revert(property)

# optional: if you want to use the revert function, return null
func _property_get_revert(_property: StringName) -> Variant:
    return null


# stuff below is just to show that it works
# if you have own custom nodes with own drawing, just get the theme property like wth all others

func _notification(what: int) -> void:
    match what:
        NOTIFICATION_THEME_CHANGED:
            self._update_layout()

func _update_layout() -> void:
    for child in self.get_children():
        if child is Label:
            if self.has_theme_color_override("my_font_color"):
                child.add_theme_color_override("font_color", self.get_theme_color("my_font_color"))
            else:
                child.remove_theme_color_override("font_color")
