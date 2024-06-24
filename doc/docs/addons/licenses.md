# License Manager

Manage license and copyright for third party graphics, software or libraries.
Group them into categories, add descriptions or web links.

The data is stored inside a json file. This file is automatically added to the export, you do not need to add it
yourself. If you provide license files instead of a text, they are also exported.

If paths are added to license data, it will be automatically adjusted if you rename a file or folder inside the editor.

You can change the project license file either with a button at the upper right, in the license menu. Or inside the
project settings under the menu `Plugins` -> `Licenses`.

## Compatibility

| Godot | Version       |
|-------|---------------|
| 4.3   | >= 1.8.0      |
| 4.2   | 1.6.0 - 1.7.8 |
| 4.1   | <= 1.5.0      |

## Screenshot

![license manager screenshot](licenses/license_manager.png "License Manager")

## Example

{{ kny:source /examples/licenses/ }}

## Interface

### Licenses

{{ kny:source /addons/licenses/licenses.gd res://addons/licenses/licenses.gd }}

Providing static utility and static functions to save and load licenses.

#### Methods

`static compare_components_ascending(lhs: Component, rhs: Component) -> bool`
:     Compare components ascending.

`static get_engine_component(name: String) -> Component`
:     Get engine component by name.

`static get_engine_components() -> Array[Component]`
:     Get all engine components.

`static get_required_engine_components() -> Array[Component]`
:     Get engine components which are marked as required to mention.

`static save(components: Array[Component], file_path: String) -> int`
:     Save array of components to file.

`static load(file_path: String) -> LoadResult`
:     Load licenses from file.

`static set_license_data_filepath(path: String) -> void`
:     Set the project license data path.

`static get_license_data_filepath() -> String`
:     Returns the project license data path.

### Component

{{ kny:badge extends RefCounted --left-bg }}

{{ kny:source "/addons/licenses/component.gd" "res://addons/licenses/component.gd" }}

Component class, data wrapper for all information regarding one license item.

#### Properties

| Name        | Type                                  | Description                                                                |
|-------------|---------------------------------------|----------------------------------------------------------------------------|
| id          | String                                | Identifier.                                                                |
| category    | String                                | Use to structure the licenses to top categories. E.g. Textures, Fonts, ... |
| name        | String                                | Name of the software or component.                                         |
| version     | String                                | Version of the software or component.                                      |
| copyright   | PackedStringArray                     | Copyrights.                                                                |
| contact     | String                                | Contact of developer.                                                      |
| description | String                                | Additional description.                                                    |
| web         | String                                | Web url to project page.                                                   |
| paths       | PackedStringArray                     | Array of String, affected files or directories.                            |
| licenses    | Array\[[License](#componentlicense)\] | Licenses.                                                                  |

#### Methods

`get_warnings() -> PackedStringArray`
:     Get warnings regarding this component, e.g. missing license.

`serialize() -> Dictionary`
:     Serialize to dictionary.

`deserialize(data: Dictionary) -> Component`
:     Load values from dictionary.

`duplicate() -> Component`
:     Returns a duplicate of itself.

### Component.License

{{ kny:badge extends RefCounted --left-bg }}

{{ kny:source "/addons/licenses/licenses.gd" "res://addons/licenses/licenses.gd" }}

License class.

#### Properties

| Name       | Type   | Description                                                                               |
|------------|--------|-------------------------------------------------------------------------------------------|
| name       | String | Full name.                                                                                |
| identifier | String | Shortcode for this license.                                                               |
| text       | String | License text.                                                                             |
| file       | String | License file. Will load the license text from this file automatically if `text` is empty. |
| web        | String | Web present of the license.                                                               |

#### Methods

`get_license_text() -> String`
:     Either returns the license text or loads the text from file or a message that the text could not be loaded.

`serialize() -> Dictionary`
:     Serialize to dictionary.

`deserialize() -> Dictionary`
:     Load values from dictionary.

`duplicate() -> License`
:     Returns a duplicate of itself.

## Changelog

### 1.8.0

- Require Godot 4.3
- Make use of @export for custom Nodes

### 1.7.8

- Detect movement of licenses json file

### 1.7.7

- Use absolute paths in preloads

### 1.7.6

- Fix scene id
- Code improvement

### 1.7.5

- Fix license file existing check

### 1.7.4

- Fix show engine component

### 1.7.3

- Fix component selection and right click menu

### 1.7.2

- Fix current selection of component on popup
- Change drag and drop behavior

### 1.7.1

- Add adjusting filepath of license files on moving
- Add more warnings
- Fix reloading UI if something was changed on moving

### 1.7.0

- Add renaming of paths when a file or folder gets renamed inside the editor
- Add right click menu to duplicate or delete items

### 1.6.1

- Workaround show engine components, calling static function is bugged

### 1.6.0

- Require Godot 4.2
- Add more values to plugin.cfg
- Add static typing in for loops
- Use static sorting function as lambda

### 1.5.0

- Removed overriden engine methods
- Creating a plugin component will now add the plugin path to paths
- Fix dragging/ double click crash
- Fix overriding project license file if another license file is loaded
- Add warning tooltip if a component paths does not exist
