# Logging

Simple logger. An autoload `GLogging` will be created on installation.
Logging methods support formatting, values won't be stringified if they are not logged.

Logging into a file is not supported. The output will be always done via print.

## Compatibility

| Godot | Version  |
| ----- | -------- |
| 4.3   | >= 1.5.0 |
| 4.2   | >= 1.5.0 |
| 4.1   | <= 1.4.1 |

## Example

{{ kny:source "/examples/glogging/" }}

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

{{ kny:source "/addons/glogging/glogging.gd" "res://addons/glogging/glogging.gd" }}

Logging base class. Provides helper methods.

#### Properties

| Name                            | Type                      | Description         |
| ------------------------------- | ------------------------- | ------------------- |
| root_logger {: .kny-mono-font } | [Logger](#glogginglogger) | root logger object. |

#### Constants

| Name                             | Type                | Value | Description         |
| -------------------------------- | ------------------- | ----- | ------------------- |
| LEVEL_NOTSET {: .kny-mono-font } | {{ kny:godot int }} | 0     | Logging level not set. |
| LEVEL_DEBUG {: .kny-mono-font } | {{ kny:godot int }} | 10     |  |
| LEVEL_INFO {: .kny-mono-font } | {{ kny:godot int }} | 20     |  |
| LEVEL_WARNING {: .kny-mono-font } | {{ kny:godot int }} | 30     |  |
| LEVEL_ERROR {: .kny-mono-font } | {{ kny:godot int }} | 40     |  |
| LEVEL_CRITICAL {: .kny-mono-font } | {{ kny:godot int }} | 50     |  |

#### Methods

void debug ( {{ kny:godot Variant }} message, {{ kny:godot Array }}[{{ kny:godot Variant }}]=[] values ) const {: .kny-mono-font }
:     log with root logger at debug level

void info ( {{ kny:godot Variant }} message, {{ kny:godot Array }}[{{ kny:godot Variant }}]=[] values ) const {: .kny-mono-font }
:     log with root logger at info level

void warning ( {{ kny:godot Variant }} message, {{ kny:godot Array }}[{{ kny:godot Variant }}]=[] values ) const {: .kny-mono-font }
:     log with root logger at warning level, will also display a debug warning

void error ( {{ kny:godot Variant }} message, {{ kny:godot Array }}[{{ kny:godot Variant }}]=[] values ) const {: .kny-mono-font }
:     with root logger at error level, will also display a debug error

void critical ( {{ kny:godot Variant }} message, {{ kny:godot Array }}[{{ kny:godot Variant }}]=[] values ) const {: .kny-mono-font }
:     log with root logger at critical level

void log ( {{ kny:godot int }} level, {{ kny:godot Variant }} message, {{ kny:godot Array }}[{{ kny:godot Variant }}]=[] values ) const {: .kny-mono-font }
:     log at a custom level

### GLogging.Logger

{{ kny:badge extends RefCounted }}

{{ kny:source "/addons/glogging/glogging.gd" "res://addons/glogging/glogging.gd" }}

Logger class.
If not log level is set, the log level of the parent logger will be used.

#### Methods

[Logger](#glogginglogger) create_child ( {{ kny:godot String }} module_name, {{ kny:godot int }} log_level=LEVEL_NOTSET) const {: .kny-mono-font }
:     create a child logger

void set_log_level ( {{ kny:godot int }} level ) {: .kny-mono-font }
:     set the log level

{{ kny:godot int }} log_level () const {: .kny-mono-font }
:     get log level

void debug ( {{ kny:godot Variant }} message, {{ kny:godot Array }}[{{ kny:godot Variant }}]=[] values) const {: .kny-mono-font }
:     log at debug level

void info ( {{ kny:godot Variant }} message, {{ kny:godot Array }}[{{ kny:godot Variant }}]=[] values) const {: .kny-mono-font }
:     log at info level

void warning ( {{ kny:godot Variant }} message, {{ kny:godot Array }}[{{ kny:godot Variant }}]=[] values) const {: .kny-mono-font }
:     log at warning level, will also display a debug warning

void error ( {{ kny:godot Variant }} message, {{ kny:godot Array }}[{{ kny:godot Variant }}]=[] values) const {: .kny-mono-font }
:     log at error level, will also display a debug error

void critical ( {{ kny:godot Variant }} message, {{ kny:godot Array }}[{{ kny:godot Variant }}]=[] values) const {: .kny-mono-font }
:     log at critical level

void log ( {{ kny:godot int }} level, {{ kny:godot Variant }} message, {{ kny:godot Array }}[{{ kny:godot Variant }}]=[] values) const {: .kny-mono-font }
:     log at custom level

## Changelog

### 1.5.1

- Code improvement

### 1.5.0

- Require Godot 4.2
- Add more values to plugin.cfg
