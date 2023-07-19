# Godot Addons

- [AspectRatioResizeContainer](#aspectratioresizecontainer)
- [Custom Theme Overrides](#custom-theme-overrides)
- [Hide Private Properties](#hide-private-properties)
- [Icons Patcher](#icons-patcher)
- [License Manager](#license-manager)
- [Logging](#logging)
- [Metadata](#metadata)
- [TextureButtonColored](#texturebuttoncolored)

## AspectRatioResizeContainer

The AspectRatioContainer allows his own size to be smaller than the children, which causes neighboring UI elements to be covered.
This new node type will extend the existing AspectRatioContainer and update it's own minimum size based on the children.
This works except for `STRETCH_MODE_COVER`.

You are also not able to use the property `custom_minimum_size` anymore as it is used to set the minimum size.

### Compatibility

- Godot 4.1

### Example

[examples/aspect_ratio_resize_container](./examples/aspect_ratio_resize_container)

## Custom Theme Overrides

If you have a custom theme for your own nodes or just need custom theme overrides in your node, this plugin will give you some helping utility.

This plugin will auto register (via `class_name`) the class `CustomThemeOverrides`.

You should not use `@export` on your variables, as they will be exported with the `_get_property_list` method. Also setter and getter will not be called inside the editor.

If everything is set up, your theme override variables can be handled like every other theme override property.

### Compatibility

- Godot 4.1

### Screenshot

![Custom theme overrides screenshot](./doc/custom_theme_overrides.png "Custom Theme Overrides")

### Example


```gdscript
# declare the members
# DO NOT
# - use @export
# - use setter and getter, they are NOT called in the editor
var my_font_color: Color
var my_border_size: int
var my_font: Font
var my_font_size: int
var my_icon: Texture2D
var my_style_box: StyleBox

# declare the custom theme overrides, use the member name and the theme data type.
var _theme_overrides = CustomThemeOverrides.new([
    ["my_font_color", Theme.DATA_TYPE_COLOR],
    ["my_border_size", Theme.DATA_TYPE_CONSTANT],
    ["my_font", Theme.DATA_TYPE_FONT],
    ["my_font_size", Theme.DATA_TYPE_FONT_SIZE],
    ["my_icon", Theme.DATA_TYPE_ICON],
    ["my_style_box", Theme.DATA_TYPE_STYLEBOX]
])

# required, if you have other properties use append_array
func _get_property_list() -> Array[Dictionary]:
    return self._theme_overrides.theme_property_list(self)

# optional: if you want to use the revert function
func _property_can_revert(property: StringName) -> bool:
    return self._theme_overrides.can_revert(property)

# optional: if you want to use the revert function, return null
func _property_get_revert(_property: StringName) -> Variant:
    return null
```

[examples/custom_theme_overrides](./examples/custom_theme_overrides)

## Hide Private Properties

Private members (names starting with an underscore) should not be exposed.

This plugin will hide exported private properties in the inspector for instantiated child scenes.

### Compatibility

- Godot 4.1

### Example

[examples/hide_private_properties](./examples/hide_private_properties)

## Icons Patcher

If you use Material Design icons from [Pictogrammers](https://pictogrammers.com/library/mdi/), they come without any fill color, automatically rendered black. This is not a convenient color as it makes it impossible to modulate the color. The icon patcher provides a utility to automatically patch the icons to white color.

Set the icon directory in the Project Settings under the menu `Plugins` -> `Icons Patcher`.

Then use `Project` -> `Tools` -> `Icons Patcher` to patch the icons.

### Compatibility

- Godot 4.1

## License Manager

Manage license and copyright for third party graphics, software or libraries.
Group them into categories, add descriptions or web links.

The data is stored inside a json file. This file is automatically added to the export, you do not need to add it yourself.

You can change the project license file either with a button at the upper right, in the license menu. Or inside the project settings under the menu `Plugins` -> `Licenses`.

### Compatibility

- Godot 4.1

### Screenshot

![license manager screenshot](./doc/license_manager.png "License Manager")

### Example

[examples/licenses](./examples/licenses)

### Classes & Functions

**Licenses** - [`addons/licenses/licenses.gd`](./addons/licenses/licenses.gd)

General class, providing among other things static functions to save and load licenses.

**Component** - [`addons/licenses/component.gd`](./addons/licenses/component.gd)

Component class, data wrapper for all  information regarding one license item.

**Component.License** - [`addons/licenses/component.gd`](./addons/licenses/component.gd)

License class.

## Logging

Simple logger. An autoload `GLogging` will be created at installation.
Logging methods support formatting, values wont be stringified if they are not logged.

Logging into a file is not supported yet. The output will be always done via print.


### Compatibility

- Godot 4.1

### Example

```
2023-07-04 15:57:16.242 [    INFO] [      root] ready and initialize GUI
2023-07-04 15:57:16.242 [    INFO] [      root] initialized logger root and other
2023-07-04 15:57:18.300 [   DEBUG] [      root] Demo Text!
2023-07-04 15:57:20.452 [    INFO] [      root] Demo Text!
2023-07-04 15:57:22.071 [ WARNING] [      root] Demo Text!
2023-07-04 15:57:24.606 [   ERROR] [      root] Demo Text!
2023-07-04 15:57:28.793 [CRITICAL] [      root] Demo Text!
2023-07-04 15:57:37.483 [    INFO] [   network] Demo Text!
2023-07-04 15:57:50.843 [    INFO] [       gui] Demo Text!
```

[examples/glogging](./examples/glogging)

### Classes & Functions

**GLogging** - [`addons/glogging/glogging.gd`](./addons/glogging/glogging.gd)

Logging base class. Provides helper methods.

- `root_logger` - root logger object
- `debug(message: Variant, values: Array[Variant] = [])` - log with root logger at debug level
- `info(message: Variant, values: Array[Variant] = [])` - log with root logger at info level
- `warning(message: Variant, values: Array[Variant] = [])` - log with root logger at warning level, will also display a debug warning
- `error(message: Variant, values: Array[Variant] = [])` - log with root logger at error level, will also display a debug error
- `critical(message: Variant, values: Array[Variant] = [])` - log with root logger at critical level
- `log(level: int, message: Variant, values: Array[Variant] = [])` - log at custom level

**GLogging.Logger** - [`addons/glogging/glogging.gd`](./addons/glogging/glogging.gd)

Logger class.
If not log level is set, the log level of the parent logger will be used.

- `create_child(module_name: String, log_level: int = LEVEL_NOTSET)` - create a child logger
- `set_log_level(level: int)` - set the log level
- `log_level() -> int` - get log level
- `debug(message: Variant, values: Array[Variant] = [])` - log at debug level
- `info(message: Variant, values: Array[Variant] = [])` - log at info level
- `warning(message: Variant, values: Array[Variant] = [])` - log at warning level, will also display a debug warning
- `error(message: Variant, values: Array[Variant] = [])` - log at error level, will also display a debug error
- `critical(message: Variant, values: Array[Variant] = [])` - log at critical level
- `log(level: int, message: Variant, values: Array[Variant] = [])` - log at custom level

## Metadata

Adds two project settings

### `application/config/version`

Define the version of your software.

### `application/config/git_sha`

This one is automatically set and updated when you run any scene or on exporting the project. The git_sha will **not** be kept in `project.godot` to not clutter any version control system.

### Compatibility

- Godot 4.1

### Example

[examples/metadata](./examples/metadata)

## TextureButtonColored

Let you apply the icon color theme properties for the texture button. Uses `self_modulate`.

### Compatibility

- Godot 4.1

### Example

[examples/texture_button_colored](./examples/texture_button_colored)


## License

[MIT License](./LICENSE.md)
