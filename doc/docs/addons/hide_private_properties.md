# Hide Private Properties

Private members (names starting with an underscore) should not be exposed.

This plugin will hide exported private properties in the inspector for instantiated child scenes.

!!! note

    You do not need to add this plugin to your credits as it is used only inside the editor and not in the final product. You can still do it if you want to.

## Compatibility

| Godot | Version  |
|-------|----------|
| 4.4   | >= 1.1.0 |
| 4.3   | >= 1.1.0 |
| 4.2   | >= 1.1.0 |
| 4.1   | <= 1.0.2 |

## Example

{{ kny:source "/examples/hide_private_properties/" }}

## Changelog

### 1.1.2

- Fix: property not found warning

### 1.1.1

- Use absolute paths in preloads

### 1.1.0

- Require Godot 4.2
- Add more values to plugin.cfg
