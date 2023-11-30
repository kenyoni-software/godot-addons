# Godot Addons

Download [here](https://github.com/kenyoni-software/godot-addons/releases/tag/latest).

## License

[MIT License](./LICENSE.md)

## Overview

### Nodes

- [AspectRatioResizeContainer](#aspectratioresizecontainer)  
  Extension of `AspectRatioContainer` to update it's own size.
- [TextureButtonColored](#texturebuttoncolored)  
  Extension of `TextureButton` with color options.
- [Logging](#logging)  
  Simple logger.
- [QR Code](#qr-code)  
  QRCodeRect and QR Code generation.

### Tools

- [Git SHA Project Setting](#git-sha-project-setting)  
  Add Git SHA as project setting.
- [Hide Private Properties](#hide-private-properties)  
  Hide private properties of instantiated child scenes.
- [Icons Patcher](#icons-patcher)  
  Patch Pictogrammers icons to white.
- [License Manager](#license-manager)  
  Manage license and copyright for third party graphics, software or libraries.

### Utility

- [Custom Theme Overrides](#custom-theme-overrides)  
  Utility to provide custom theme overrides for any node.

---

## AspectRatioResizeContainer

The `AspectRatioContainer` allows his own size to be smaller than the children, which causes neighboring UI elements to be covered.
This new node type will extend the existing `AspectRatioContainer` and update it's own minimum size based on the children.
This works except for `STRETCH_MODE_COVER`.

You are also not able to use the property `custom_minimum_size` anymore as it is used to set the minimum size.

### Compatibility

- Godot 4.2

### Example

[examples/aspect_ratio_resize_container](./examples/aspect_ratio_resize_container)

### Changelog

#### 3.1.0

- Require Godot 4.2
- Add more values to plugin.cfg
- Add static typing in for loops

---

## Custom Theme Overrides

Utility to make custom theme overrides for any node possible.

This plugin will auto register (via `class_name`) the class `CustomThemeOverrides`.

You should not use `@export` on your custom theme variables, as they will be exported with the `_get_property_list` method. Also setter and getter will not be called inside the editor.

If everything is set up, your theme override variables can be handled like every other theme override property.

### Compatibility

- Godot 4.2

### Screenshot

![Custom theme overrides screenshot](./doc/custom_theme_overrides.png "Custom Theme Overrides")

### Example

```gdscript
# declare the members
# DO NOT
# - use @export
# - use setter and getter, they are NOT called in the editor
# - access these variables directly
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

### Changelog

#### 1.1.0

- Require Godot 4.2
- Add more values to plugin.cfg
- Add static typing in for loops

---

## Git SHA Project Setting

Previously named `Metadata`.

Adds the project setting `application/config/git_sha`, which contains the current Git SHA.
This one is automatically set and updated when you run any scene or on exporting the project. The git_sha will **not** be kept in `project.godot` to not clutter any version control system. It will be removed from the settings on closing the Godot Editor.

### Compatibility

- Godot 4.2

### Example

[examples/metadata](./examples/metadata)

### Changelog

#### 2.1.0

- Require Godot 4.2
- Add more values to plugin.cfg

#### 2.0.0

- Added an initial Git SHA load on opening the project.
- Removed `application/config/version`, there was no need that this was part of the addon. The value can still be added manually.

---

## Hide Private Properties

Private members (names starting with an underscore) should not be exposed.

This plugin will hide exported private properties in the inspector for instantiated child scenes.

### Compatibility

- Godot 4.2

### Example

[examples/hide_private_properties](./examples/hide_private_properties)

### Changelog

#### 1.1.0

- Require Godot 4.2
- Add more values to plugin.cfg

---

## Icons Patcher

If you use Material Design icons from [Pictogrammers](https://pictogrammers.com/library/mdi/), they come without any fill color, automatically rendered black. This is not a convenient color as it makes it impossible to modulate the color. The icon patcher provides a utility to automatically patch the icons to white color.

Set the icon directory in the Project Settings under the menu `Plugins` -> `Icons Patcher`.

Then use `Project` -> `Tools` -> `Icons Patcher` to patch the icons.

### Compatibility

- Godot 4.2

### Changelog

#### 1.3.0

- Require Godot 4.2
- Add more values to plugin.cfg

#### 1.2.0

- Added automatic file reimporting.

---

## License Manager

Manage license and copyright for third party graphics, software or libraries.
Group them into categories, add descriptions or web links.

The data is stored inside a json file. This file is automatically added to the export, you do not need to add it yourself. If you provide license files instead of a text, they are also exported.

You can change the project license file either with a button at the upper right, in the license menu. Or inside the project settings under the menu `Plugins` -> `Licenses`.

### Compatibility

- Godot 4.2

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

### Changelog

#### 1.6.0

- Require Godot 4.2
- Add more values to plugin.cfg
- Add static typing in for loops
- Use static sorting function as lambda

#### 1.5.0

- Removed overriden engine methods
- Creating a plugin component will now add the plugin path to paths
- Fix dragging/ double click crash
- Fix overriding project license file if another license file is loaded
- Add warning tooltip if a component paths does not exist

---

## Logging

Simple logger. An autoload `GLogging` will be created at installation.
Logging methods support formatting, values wont be stringified if they are not logged.

Logging into a file is not supported yet. The output will be always done via print.


### Compatibility

- Godot 4.2

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

- `root_logger: Logger`  
  root logger object
- `debug(message: Variant, values: Array[Variant] = []) -> void`  
  log with root logger at debug level
- `info(message: Variant, values: Array[Variant] = []) -> void`  
  log with root logger at info level
- `warning(message: Variant, values: Array[Variant] = []) -> void`  
  log with root logger at warning level, will also display a debug warning
- `error(message: Variant, values: Array[Variant] = []) -> void`  
  log with root logger at error level, will also display a debug error
- `critical(message: Variant, values: Array[Variant] = []) -> void`  
  log with root logger at critical level
- `log(level: int, message: Variant, values: Array[Variant] = []) -> void`  
  log at custom level

**GLogging.Logger** - [`addons/glogging/glogging.gd`](./addons/glogging/glogging.gd)

Logger class.
If not log level is set, the log level of the parent logger will be used.

- `create_child(module_name: String, log_level: int = LEVEL_NOTSET) -> Logger`  
  create a child logger
- `set_log_level(level: int) -> void`  
  set the log level
- `log_level() -> int`  
  get log level
- `debug(message: Variant, values: Array[Variant] = []) -> void`  
  log at debug level
- `info(message: Variant, values: Array[Variant] = []) -> void`  
  log at info level
- `warning(message: Variant, values: Array[Variant] = []) -> void`  
  log at warning level, will also display a debug warning
- `error(message: Variant, values: Array[Variant] = []) -> void`  
  log at error level, will also display a debug error
- `critical(message: Variant, values: Array[Variant] = []) -> void`  
  log at critical level
- `log(level: int, message: Variant, values: Array[Variant] = []) -> void`  
  log at custom level

### Changelog

#### 1.5.0

- Require Godot 4.2
- Add more values to plugin.cfg

---

## QR Code

QR Code generation either with the included `QRCodeRect` node or use the encoding result of the `QRCode` class.

### Compatibility

- Godot 4.2

### Screenshot

![QRCodeRect node inspector screenshot](./doc/qr_code.png "QRCodeRect in inspector")

### Example

[examples/qr_code](./examples/qr_code)

### Classes & Functions

**QRCodeRect** - [`addons/qr_code/qr_code_rect.gd`](./addons/qr_code/qr_code_rect.gd)

`TextureRect` like node. The texture is updated by itself.
When using byte encoding you can also pass strings for specific ECI values (ISO 8859-1, Shift JIS, UTF-8, UTF-16, US ASCII), the input string will be automatically converted to an byte array.

#### Properties

- `mode: QRCode.Mode`
- `error_correction: QRCode.ErrorCorrection`
- `use_eci: bool`  
  Use Extended Channel Interpretation (ECI)
- `eci_value: int`  
  Extended Channel Interpretation (ECI) Value
- `data: Variant`  
  Type varies based on the encoding mode.
- `auto_version: bool`  
  Use automatically the smallest QR Code version.
- `version: int`
- `auto_mask_pattern: bool`  
  Use automatically the best mask pattern.
- `mask_pattern: int`
- `light_module_color: Color`
- `dark_module_color: Color`
- `auto_module_px_size: bool`  
  Automatically set the module pixel size based on the size.  
  Do not use expand mode KEEP_SIZE when using it.  
  Turn this off when the QR Code changes or is resized often, as it impacts the performance quite heavily.
- `module_px_size: int`  
  Use that many pixel for one module.
- `quiet_zone_size: int`  
  Use that many modules for the quiet zone. A value of 4 is recommended.

**QRCode** - [`addons/qr_code/qr_code.gd`](./addons/qr_code/qr_code.gd)

QRCode class to generate QR Codes.

#### Enums

- `Mode`  
  Encoding mode enum.
  - `NUMERIC = 1`
  - `ALPHANUMERIC = 2`
  - `BYTE = 4`
  - `KANJI = 8`
- `ErrorCorrection`  
  Error correction enum.
  - `LOW = 1`
  - `MEDIUM = 0`
  - `QUARTILE = 3`
  - `HIGH = 2`
- `ECI`  
  Extended Channel Interpretation enum. Provides some values by name.

#### Properties

- `mode: Mode`
- `error_correction: ErrorCorrection`
- `use_eci: bool`  
  Use Extended Channel Interpretation (ECI)
- `eci_value: int`  
  Extended Channel Interpretation (ECI) Value
- `auto_version: bool`  
  Use automatically the smallest QR Code version.
- `version: int`
- `auto_mask_pattern: bool`  
  Use automatically the best mask pattern.
- `mask_pattern: int`

#### Methods

- `get_module_count() -> int`  
  Get the module count per side.
- `calc_min_version() -> int`  
  Get the minimal version required to encode the data.
- `generate_image(module_px_size: int = 1, light_module_color: Color = Color.WHITE, dark_module_color: Color = Color.BLACK) -> Image`  
  Generate an image. This method can be called repeatedly, as encoding will only happens once and be cached.
- `put_numeric(number: String) -> void`  
  Put a numeric text as data. Invalid characters are removed. Will change the encoding mode to `Mode.NUMERIC`.
- `put_alphanumeric(text: String) -> void`  
  Put a alphanumeric text as data. Invalid characters are removed. Will change the encoding mode to `Mode.ALPHANUMERIC`.
- `put_byte(data: PackedByteArray) -> void`  
  Put a byte data. Will change the encoding mode to `Mode.BYTE`.
- `put_numeric(number: String) -> void`  
  Put a numeric text as data. Invalid characters are removed. Will change the encoding mode to `Mode.KANJI`.
- `encode() -> PackedByteArray`  
  Get the QR Code row by row in one array. To get the row size use `get_module_count`.

**ShiftJIS** - [`addons/qr_code/shift_jis.gd`](./addons/qr_code/shift_jis.gd)

Shift JIS encoding utility.

### Functions

- `static func to_shift_jis_2004_buffer(text: String) -> PackedByteArray`
- `static func get_string_from_shift_jis_2004(arr: PackedByteArray) -> String`
- `static func to_jis_8_buffer(text: String) -> PackedByteArray`
- `static func get_string_from_jis_8(arr: PackedByteArray) -> String`

### Changelog

#### 1.1.0

- Require Godot 4.2
- Add more values to plugin.cfg
- Add static typing in for loops

#### 1.0.0

- Renamed `get_string_from_jis_2004` to `get_string_from_shift_jis_2004`

#### 0.3.1

- Improve inspector properties
- Improve input handling of byte data based on ECI usage

#### 0.3.0

- Make ECI value optional

#### 0.2.0

- Added quiet zone size property

---

## TextureButtonColored

Let you apply the icon color theme properties for the texture button. Uses `self_modulate`.

### Compatibility

- Godot 4.2

### Dependencies

- [Custom Theme Overrides](#custom-theme-overrides)

### Example

[examples/texture_button_colored](./examples/texture_button_colored)

### Changelog

#### 1.3.0

- Require Godot 4.2
- Add more values to plugin.cfg

#### 1.2.3

- Rename method `get_theme_color` to `get_theme_coloring`, this function was never called by the engine anyway and should not be overridden
