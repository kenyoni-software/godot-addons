---
description: "Hides exported private properties from instantiated scenes."
---

# Hide Private Properties

Private members (names starting with an underscore) should not be exposed.

This plugin hides exported private properties from instantiated scenes, that they cannot be accidentally overridden.

{{ kny:badge-version "1.3.0" }}  
You can change this behavior in the editor settings under `Interface -> Inspector -> Hide Private Properties`. It will be enabled by default.  
To search for overridden properties, this plugin will give you a dialog under `Project -> Tools -> Scan for private property overrides...`

[**Download**](https://github.com/kenyoni-software/godot-addons/releases/tag/latest)

## Compatibility

| Godot | Version  |
| ----- | -------- |
| 4.7   | >= 1.1.0 |
| 4.6   | >= 1.1.0 |
| 4.5   | >= 1.1.0 |
| 4.4   | >= 1.1.0 |
| 4.3   | >= 1.1.0 |
| 4.2   | >= 1.1.0 |
| 4.1   | <= 1.0.2 |

## Example

{{ kny:source "/examples/hide_private_properties/" }}

## Changelog

### 1.4.0

- Upgrade scenes to Godot 4.6

### 1.3.2

- Code improvements

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
