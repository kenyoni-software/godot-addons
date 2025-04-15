# Hide Private Properties

Private members (names starting with an underscore) should not be exposed.

This plugin hides exported private properties from instantiated scenes, that they cannot be accidentally overridden.

{{ kny:badge-version "1.3.0" }}  
You can change this behavior in the editor settings under `Interface -> Inspector -> Hide Private Properties`. It will be enabled by default.  
To search for overridden properties, this plugin will give you a dialog under `Project -> Tools -> Scan for private property overrides...`

!!! note "Credits"

    You are not required to credit this plugin in your in-app credits, as it is only used within the editor and not in the final product. However, you may do so if you wish.

[**Download**](https://github.com/kenyoni-software/godot-addons/releases)

## Compatibility

| Godot | Version  |
| ----- | -------- |
| 4.4   | >= 1.1.0 |
| 4.3   | >= 1.1.0 |
| 4.2   | >= 1.1.0 |
| 4.1   | <= 1.0.2 |

## Example

{{ kny:source "/examples/hide_private_properties/" }}

## Changelog

### 1.3.1

- Code improvements

### 1.3.0

- Add Editor setting to enable/disable hiding private properties
- Add dialog to search for overridden properties

### 1.2.0

- Add UIDs for Godot 4.4

### 1.1.2

- Fix: property not found warning

### 1.1.1

- Use absolute paths in preloads

### 1.1.0

- Require Godot 4.2
- Add more values to plugin.cfg
