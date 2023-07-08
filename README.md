# Godot Addons

- [Icons Patcher](#icons-patcher)
- [License Manager](#license-manager)
- [Logging](#logging)
- [Metadata](#metadata)

## Icons Patcher

If you use Material Design icons from [Pictogrammers](https://pictogrammers.com/library/mdi/), they come without any fill color, automatically rendered black. This is not a convenient color as it makes it impossible to modulate the color. The icon patcher provides a utility to automatically patch the icons to white color.

Set the icon directory in the Project Settings under the menu `Plugins` -> `Icons Patcher`.

Then use `Project` -> `Tools` -> `Icons Patcher` to patch the icons.

## License Manager

Manage license and copyright for third party graphics, software or libraries.
Group them into categories, add descriptions or web links.

The data is stored inside a json file. This file is automatically added to the export, you do not need to add it yourself.

You can change the project license file either with a button at the upper right, in the license menu. Or inside the project settings under the menu `Plugins` -> `Licenses`.

### Screenshot

![license manager screenshot](./doc/license_manager.png "License Manager")

### Example

[examples/licenses](./examples/licenses)

### Compatibility

- Godot 4.1

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

### Output

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

### Example

[examples/glogging](./examples/glogging)

### Compatibility

- Godot 4.1

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

### Example

[examples/metadata](./examples/metadata)

### Compatibility

- Godot 4.1

## License

[MIT License](./LICENSE.md)
