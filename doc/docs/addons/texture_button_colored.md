# TextureButtonColored

Let you apply the icon color theme properties for the texture button. Uses `self_modulate`.

[**Download**](https://github.com/kenyoni-software/godot-addons/releases)

## Compatibility

| Godot | Version       |
| ----- | ------------- |
| 4.4   | >= 1.4.0      |
| 4.3   | >= 1.4.0      |
| 4.2   | 1.3.0 - 1.3.2 |
| 4.1   | <= 1.2.3      |

## Dependencies

- [Custom Theme Overrides](custom_theme_overrides.md)

## Example

{{ kny:source /examples/texture_button_colored/ }}

## Interface

### TextureButtonColored

{{ kny:badge extends TextureButton --left-bg }}

{{ kny:source "/addons/custom_theme_overrides/texture_button_colored.gd" "res://addons/custom_theme_overrides/texture_button_colored.gd" }}

#### Theme Overrides

| Name                                         | Type                  |
| -------------------------------------------- | --------------------- |
| icon_normal_color {: .kny-mono-font }        | {{ kny:godot Color }} |
| icon_pressed_color {: .kny-mono-font }       | {{ kny:godot Color }} |
| icon_hover_color {: .kny-mono-font }         | {{ kny:godot Color }} |
| icon_hover_pressed_color {: .kny-mono-font } | {{ kny:godot Color }} |
| icon_focus_color {: .kny-mono-font }         | {{ kny:godot Color }} |
| icon_disabled_color {: .kny-mono-font }      | {{ kny:godot Color }} |

## Changelog

### 1.5.1

- Apply correct Godot version in metadata (4.3)

### 1.5.0

- Add UIDs for Godot 4.4

### 1.4.0

- Remove editor toast notification (access was removed)

### 1.3.3

- Notify if Custom Themes Override is missing or enable it if disabled

### 1.3.2

- Use absolute paths in preloads

### 1.3.1

- Code improvement

### 1.3.0

- Require Godot 4.2
- Add more values to plugin.cfg

### 1.2.3

- Rename method `get_theme_color` to `get_theme_coloring`, this function was never called by the engine anyway and should not be overridden
