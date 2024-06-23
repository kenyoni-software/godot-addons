# Logging

Simple logger. An autoload `GLogging` will be created on installation.
Logging methods support formatting, values won't be stringified if they are not logged.

Logging into a file is not supported. The output will be always done via print.

## Compatibility

| Godot | Version  |
|-------|----------|
| 4.3   | >= 1.5.0 |
| 4.2   | >= 1.5.0 |
| 4.1   | <= 1.4.1 |

## Example

{{ kny:source /examples/glogging/ }}

Example output.

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

## Interface

### GLogging

{{ kny:source /addons/glogging/glogging.gd res://addons/glogging/glogging.gd }}

Logging base class. Provides helper methods.

#### Properties

| Name        | Type                      | Description         |
|-------------|---------------------------|---------------------|
| root_logger | [Logger](#glogginglogger) | root logger object. |

#### Methods

`debug(message: Variant, values: Array[Variant] = []) -> void`
:     log with root logger at debug level

`info(message: Variant, values: Array[Variant] = []) -> void`
:     log with root logger at info level

`warning(message: Variant, values: Array[Variant] = []) -> void`
:     log with root logger at warning level, will also display a debug warning

`error(message: Variant, values: Array[Variant] = []) -> void`
:     with root logger at error level, will also display a debug error

`critical(message: Variant, values: Array[Variant] = []) -> void`
:     log with root logger at critical level

`log(level: int, message: Variant, values: Array[Variant] = []) -> void`
:     log at a custom level

### GLogging.Logger

{{ kny:badge extends RefCounted }}

{{ kny:source /addons/glogging/glogging.gd res://addons/glogging/glogging.gd }}

Logger class.
If not log level is set, the log level of the parent logger will be used.

#### Methods

`create_child(module_name: String, log_level: int = LEVEL_NOTSET) -> Logger`
:     create a child logger

`set_log_level(level: int) -> void`
:     set the log level

`log_level() -> int`
:     get log level

`debug(message: Variant, values: Array[Variant] = []) -> void`
:     log at debug level

`info(message: Variant, values: Array[Variant] = []) -> void`
:     log at info level

`warning(message: Variant, values: Array[Variant] = []) -> void`
:     log at warning level, will also display a debug warning

`error(message: Variant, values: Array[Variant] = []) -> void`
:     log at error level, will also display a debug error

`critical(message: Variant, values: Array[Variant] = []) -> void`
:     log at critical level

`log(level: int, message: Variant, values: Array[Variant] = []) -> void`
:     log at custom level

## Changelog

### 1.5.1

- Code improvement

### 1.5.0

- Require Godot 4.2
- Add more values to plugin.cfg
