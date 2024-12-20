# AspectRatioResizeContainer

The `AspectRatioContainer` allows his own size to be smaller than the children, which causes neighboring UI elements to be covered.
This new node type will extend the existing `AspectRatioContainer` and update it's own minimum size based on the children.
This works except for `STRETCH_MODE_COVER`.

!!! warning

    You cannot use the property `custom_minimum_size` anymore as it is used to set the minimum size.

## Compatibility

| Godot | Version  |
|-------|----------|
| 4.4   | >= 3.1.0 |
| 4.3   | >= 3.1.0 |
| 4.2   | >= 3.1.0 |
| 4.1   | <= 3.0.2 |

## Example

{{ kny:source "/examples/aspect_ratio_resize_container/" }}

## Changelog

### 3.2.2

- Add more static typing

### 3.2.1

- Revert: Fix ratio calculation, it is clunky on specific settings

### 3.2.0

- Fix ratio calculation (but it's still bugged in some cases)

### 3.1.2

- Use absolute paths in preloads

### 3.1.1

- Code improvement

### 3.1.0

- Require Godot 4.2
- Add more values to plugin.cfg
- Add static typing in for loops
