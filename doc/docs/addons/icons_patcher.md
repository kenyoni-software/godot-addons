# Icons Patcher

!!! danger "Deprecated"

    Use [Icon Explorer](icon_explorer.md) and save icons in white color.

If you use Material Design icons from [Pictogrammers](https://pictogrammers.com/library/mdi/), they come without any fill color, automatically rendered black. This is not a convenient color as it makes it impossible to modulate the color. The icon patcher provides a utility to automatically patch the icons to white color.

Set the icon directory in the Project Settings under the menu `Plugins` -> `Icons Patcher`.

Then use `Project` -> `Tools` -> `Icons Patcher` to patch the icons.

[**Download**](https://github.com/kenyoni-software/godot-addons/releases)

## Compatibility

| Godot | Version  |
|-------|----------|
| 4.3   | >= 1.5.0 |
| 4.2   | >= 1.3.0 |
| 4.1   | <= 1.2.1 |

## Changelog

### 1.5.0

- Remove editor toast notification (access was removed)

### 1.4.0

- Use editor toast notification

### 1.3.3

- Use absolute paths in preloads

### 1.3.2

- Code improvement

### 1.3.1

- Replace legacy code

### 1.3.0

- Require Godot 4.2
- Add more values to plugin.cfg

### 1.2.0

- Added automatic file reimporting.
