# Tolgee

Integration for [Tolgee](https://tolgee.io/) translation platform. This is **not** an official integration.  
Both Godot localization workflows `CSV` and `gettext` are supported. Self hosted or local running instances are supported as well.

This plugin is not intended for larger teams and collaborative translating, it does not solve any problems coming with parallel developing of different translations. The main point to solve, is having a nice editor / platform to edit translations and syncing them with your project. Especially with a locally self hosted instance of Tolgee.

This plugin allows to define translation files and pushing them to Tolgee, as well as pulling translations back to your project. Both syncing directions are destructive, meaning that the translations in your project will be overwritten by the translations in Tolgee and vice versa.

## Workflows

### CSV

Define CSV files in your project. The plugin will push the translations to Tolgee and pull them back to generate CSV files.

### Gettext

Use the POT generation feature of Godot to create template files. This plugin will synchronize the translation keys to Tolgee and pull the translations back to generate PO files, which will Godot then use to load the translations.  
Tolgee does not support merging of POT files, so you need to solve merge conflicts manually, this is especially important when renaming translation keys.

[**Download**](https://github.com/kenyoni-software/godot-addons/releases)

## Compatibility

| Godot | Version  |
|-------|----------|
| 4.4   | >= 1.0.0 |

## Example

{{ kny:source "/examples/tolgee/" }}

## Changelog

### 0.1.0

- Initial beta release
