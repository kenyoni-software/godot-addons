# Icon Explorer

Browse and save icons from popular icon collections.

You will find the Icon Explorer under `Project -> Tools -> Icon Explorer...` or directly in the main screen.

Install or update them via the options menu in the right upper corner. This can take several minutes.

You can remove the main screen button in the options, the editor has to be restarted to take it into effect.

[**Download**](https://github.com/kenyoni-software/godot-addons/releases)

**Available collections**

- [Bootstrap Icons](https://github.com/twbs/icons) (since `1.0.0`)
- [country-flag-icons](https://gitlab.com/catamphetamine/country-flag-icons) (since `1.2.0`)
- [Font Awesome 6](https://github.com/FortAwesome/Font-Awesome) (since `1.0.0`)
- [Material Design](https://github.com/Templarian/MaterialDesign-SVG) (since `1.0.0`)
- [Simple Icons](https://github.com/simple-icons/simple-icons) (since `1.0.0`)
- [tabler Icons](https://github.com/tabler/tabler-icons) (since `1.0.0`)

!!! note

    Downloaded data is saved into `.godot/cache/icon_explorer` to avoid importing it.

## Compatibility

| Godot | Version  |
|-------|----------|
| 4.3   | >= 1.2.0 |
| 4.2   | <= 1.1.0 |

## Screenshot

In Main screen:

![Icon Explorer screenshot](icon_explorer/main_screen.png "In Main Screen")

As popup:

![Icon Explorer screenshot](icon_explorer/popup.png "As Popup")

## Changelog

### 1.3.0

- Support Tabler Icons 3 (you might need to reinstall this collection)
- Support Simple Icons 14
- Improve download speed and reduce installation time
- Improve Font Awesome icon loading

### 1.2.0

- Require Godot 4.3
- Make use of @export for custom Nodes
- Improve loading visualization
- Add Icons to Main Screen (this is optional and can be turned off)
- Add check for updates button
- Remove editor toast notification (access was removed)
- Focus filter input on opening

### 1.1.0

- Use editor toast notification

### 1.0.0

- Add icon explorer
