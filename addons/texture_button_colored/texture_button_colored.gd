@tool
extends TextureButton
class_name TextureButtonColored

# Ignore these variables
var icon_normal_color: Color
var icon_pressed_color: Color
var icon_hover_color: Color
var icon_hover_pressed_color: Color
var icon_focus_color: Color
var icon_disabled_color: Color

var _is_hovered: bool = false

var _theme_overrides = CustomThemeOverrides.new([
    ["icon_normal_color", Theme.DATA_TYPE_COLOR],
    ["icon_pressed_color", Theme.DATA_TYPE_COLOR],
    ["icon_hover_color", Theme.DATA_TYPE_COLOR],
    ["icon_hover_pressed_color", Theme.DATA_TYPE_COLOR],
    ["icon_focus_color", Theme.DATA_TYPE_COLOR],
    ["icon_disabled_color", Theme.DATA_TYPE_COLOR]
])

## Provides the same functionality as get_theme_color, but will also return TextureButtonColored theme properties
func get_theme_coloring(name: StringName, theme_type: StringName = "") -> Color:
    if self.has_theme_color(name, theme_type):
        return super.get_theme_color(name, theme_type)
    return super.get_theme_color(name, &"TextureButtonColored")

func _get_property_list() -> Array[Dictionary]:
    return self._theme_overrides.theme_property_list(self)

func _property_can_revert(property: StringName) -> bool:
    return self._theme_overrides.can_revert(property)

func _property_get_revert(_property: StringName) -> Variant:
    return null

func _notification(what: int) -> void:
    match what:
        NOTIFICATION_THEME_CHANGED:
            self._update_layout()
        NOTIFICATION_MOUSE_ENTER:
            self._is_hovered = true
        NOTIFICATION_MOUSE_EXIT:
            self._is_hovered = false

func _draw() -> void:
    self._update_layout()

func _update_layout() -> void:
    var draw_mode: int = self.get_draw_mode()
    if draw_mode == DRAW_HOVER_PRESSED || (self._is_hovered && self.button_pressed):
        self.self_modulate = self.get_theme_coloring(&"icon_hover_pressed_color")
    elif draw_mode == DRAW_NORMAL:
        self.self_modulate = self.get_theme_coloring(&"icon_normal_color")
    elif draw_mode == DRAW_PRESSED:
        self.self_modulate = self.get_theme_coloring(&"icon_pressed_color")
    elif draw_mode == DRAW_HOVER:
        self.self_modulate = self.get_theme_coloring(&"icon_hover_color")
    elif draw_mode == DRAW_DISABLED:
        self.self_modulate = self.get_theme_coloring(&"icon_disabled_color")
    elif self.has_focus():
        self.self_modulate = self.get_theme_coloring(&"icon_hover_pressed_color")
