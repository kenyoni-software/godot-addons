---
description: "Simple logging utility."
---

# Logging

Download: [**GitHub**](https://github.com/kenyoni-software/godot-addons/releases)

Simple logger. An autoload `GLogging` will be created on installation.
Logging methods support formatting, values won't be stringified if they are not logged.

Logging into a file is not supported. The output will be always done via print.

## Compatibility

| Godot | Version       |
| ----- | ------------- |
| 4.7   | >= 2.0.0      |
| 4.6   | >= 2.0.0      |
| 4.5   | >= 2.0.0      |
| 4.4   | 1.5.0 - 1.6.1 |
| 4.3   | 1.5.0 - 1.6.1 |
| 4.2   | 1.5.0 - 1.6.1 |
| 4.1   | <= 1.4.1      |

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

!!! note "Godot 4.5. or higher"

    Due to Godot adding it's own `Logger` class, the class is renamed to `GLogger` in 2.0.0 and higher.

### GLogging

{{ kny:source "/addons/glogging/glogging.gd" "res://addons/glogging/glogging.gd" }}

Logging base class. Provides helper methods.

#### Properties

| Name                            | Type                                            | Description         |
| ------------------------------- | ----------------------------------------------- | ------------------- |
| root_logger {: .kny-mono-font } | [GLogger](#gloggingglogger) {: .kny-mono-font } | root logger object. |

#### Constants

| Name                               | Type                | Value | Description            |
| ---------------------------------- | ------------------- | ----- | ---------------------- |
| LEVEL_NOTSET {: .kny-mono-font }   | {{ kny:godot int }} | 0     | Logging level not set. |
| LEVEL_DEBUG {: .kny-mono-font }    | {{ kny:godot int }} | 10    |                        |
| LEVEL_INFO {: .kny-mono-font }     | {{ kny:godot int }} | 20    |                        |
| LEVEL_WARNING {: .kny-mono-font }  | {{ kny:godot int }} | 30    |                        |
| LEVEL_ERROR {: .kny-mono-font }    | {{ kny:godot int }} | 40    |                        |
| LEVEL_CRITICAL {: .kny-mono-font } | {{ kny:godot int }} | 50    |                        |

#### Methods

void debug(message: {{ kny:godot Variant }}, values: {{ kny:godot Array }}[{{ kny:godot Variant }}]=[]) const {: .kny-mono-font }
:     log with root logger at debug level

void info(message: {{ kny:godot Variant }}, values: {{ kny:godot Array }}[{{ kny:godot Variant }}]=[]) const {: .kny-mono-font }
:     log with root logger at info level

void warning(message: {{ kny:godot Variant }}, values: {{ kny:godot Array }}[{{ kny:godot Variant }}]=[]) const {: .kny-mono-font }
:     log with root logger at warning level, will also display a debug warning

void error(message: {{ kny:godot Variant }}, values: {{ kny:godot Array }}[{{ kny:godot Variant }}]=[]) const {: .kny-mono-font }
:     with root logger at error level, will also display a debug error

void critical(message: {{ kny:godot Variant }}, values: {{ kny:godot Array }}[{{ kny:godot Variant }}]=[]) const {: .kny-mono-font }
:     log with root logger at critical level

void log(level: {{ kny:godot int }}, message: {{ kny:godot Variant }}, values: {{ kny:godot Array }}[{{ kny:godot Variant }}]=[]) const {: .kny-mono-font }
:     log at a custom level

### GLogging.GLogger

{{ kny:badge extends RefCounted }}

{{ kny:source "/addons/glogging/glogging.gd" "res://addons/glogging/glogging.gd" }}

Logger class.
If not log level is set, the log level of the parent logger will be used.

#### Methods

[GLogger](#gloggingglogger) create_child(module_name: {{ kny:godot String }}, log_level: {{ kny:godot int }}=LEVEL_NOTSET) const {: .kny-mono-font }
:     create a child logger

void set_log_level(level: {{ kny:godot int }}) {: .kny-mono-font }
:     set the log level

{{ kny:godot int }} log_level() const {: .kny-mono-font }
:     get log level

void debug(message: {{ kny:godot Variant }}, values: {{ kny:godot Array }}[{{ kny:godot Variant }}]=[]) const {: .kny-mono-font }
:     log at debug level

void info(message: {{ kny:godot Variant }}, values: {{ kny:godot Array }}[{{ kny:godot Variant }}]=[]) const {: .kny-mono-font }
:     log at info level

void warning(message: {{ kny:godot Variant }}, values: {{ kny:godot Array }}[{{ kny:godot Variant }}]=[]) const {: .kny-mono-font }
:     log at warning level, will also display a debug warning

void error(message: {{ kny:godot Variant }}, values: {{ kny:godot Array }}[{{ kny:godot Variant }}]=[]) const {: .kny-mono-font }
:     log at error level, will also display a debug error

void critical(message: {{ kny:godot Variant }}, values: {{ kny:godot Array }}[{{ kny:godot Variant }}]=[]) const {: .kny-mono-font }
:     log at critical level

void log(level: {{ kny:godot int }}, message: {{ kny:godot Variant }}, values: {{ kny:godot Array }}[{{ kny:godot Variant }}]=[]) const {: .kny-mono-font }
:     log at custom level

## Changelog

### 2.0.0

- Rename `Logger` to `GLogger` (Godot has a `Logger` class now)

### 1.6.1

- Code improvements

### 1.6.0

- Add UIDs for Godot 4.4

### 1.5.1

- Code improvement

### 1.5.0

- Require Godot 4.2
- Add more values to plugin.cfg
