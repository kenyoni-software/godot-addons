# Git SHA Project Setting

!!! note

    Previously named `Metadata`.

Adds the project setting `application/config/git_sha`, which contains the current Git SHA.
It will be automatically set and updated when you run any scene or export the project.

The Git SHA will **not** be kept in `project.godot` to not clutter any version control system. It will be removed from the settings on closing the Godot Editor.

## Compatibility

| Godot | Version  |
|-------|----------|
| 4.4   | >= 2.1.0 |
| 4.3   | >= 2.1.0 |
| 4.2   | >= 2.1.0 |
| 4.1   | <= 2.0.0 |

## Example

{{ kny:source "/examples/git_sha_project_setting/" }}

## Changelog

### 2.1.1

- Use absolute paths in preloads

### 2.1.0

- Require Godot 4.2
- Add more values to plugin.cfg

### 2.0.0

- Added an initial Git SHA load on opening the project.
- Removed `application/config/version`, there was no need that this was part of the addon. The value can still be added manually.
