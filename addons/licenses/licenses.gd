extends RefCounted
# TODO:  DO NOT USE THE CLASS NAME, it will be removed later
class_name __LicenseManager

const Component := preload("res://addons/licenses/component.gd")

const DATA_FILE: String = "plugins/licenses/data_file"

static func compare_components_ascending(lhs: Component, rhs: Component) -> bool:
    var lhs_cat_lower: String = lhs.category.to_lower()
    var rhs_cat_lower: String = rhs.category.to_lower()
    return lhs_cat_lower < rhs_cat_lower || (lhs_cat_lower == rhs_cat_lower && lhs.name.to_lower() < rhs.name.to_lower())

static func get_engine_component(name: String) -> Component:
    var license_keys: Array = Engine.get_license_info().keys()
    for info: Dictionary in Engine.get_copyright_info():
        if info["name"] != name:
            continue
        var component: Component = Component.new()
        component.readonly = true
        component.id = info["name"].to_snake_case()
        component.category = "Engine Components"
        component.name = info["name"]

        component.copyright = info["parts"][0]["copyright"]
        var license_str: String = info["parts"][0]["license"]
        for license_key: String in license_keys:
            if license_key in license_str:
                var license: Component.License = Component.License.new()
                license.name = license_key
                if license.name == "Expat":
                    license.name = "MIT License"
                    license.identifier = "MIT"
                license.text = Engine.get_license_info()[license_key]
                component.licenses.append(license)

        if info["name"] == "Godot Engine":
            component.version = Engine.get_version_info().string
            component.web = "https://godotengine.org/"
            component.licenses[0].text = Engine.get_license_text()
            component.licenses[0].web = "https://godotengine.org/license"

        return component
    return null

static func get_engine_components() -> Array[Component]:
    var engine_components: Array[Component] = []

    for info: Dictionary in Engine.get_copyright_info():
        var eg_comp: Component = get_engine_component(info["name"])
        if eg_comp != null:
            engine_components.append(eg_comp)

    engine_components.sort_custom(__LicenseManager.compare_components_ascending)
    return engine_components

static func get_required_engine_components() -> Array[Component]:
    var engine_components: Array[Component] = []

    for name: String in ["Godot Engine", "ENet", "The FreeType Project", "Mbed TLS"]:
        var eg_comp: Component = get_engine_component(name)
        if eg_comp != null:
            engine_components.append(eg_comp)

    engine_components.sort_custom(__LicenseManager.compare_components_ascending)
    return engine_components

static func save(components: Array[Component], file_path: String) -> int:
    var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
    if file == null:
        return FileAccess.get_open_error()
    var raw: Array = []
    for component: Component in components:
        raw.append(component.serialize())
    file.store_line(JSON.stringify({"components": raw}))
    file = null
    return OK

class LoadResult:
    extends RefCounted

    var components: Array[Component]
    var err_msg: String = ""

    func _init(components: Array[Component], err_msg: String = "") -> void:
        self.components = components
        self.err_msg = err_msg

static func load(file_path: String) -> LoadResult:
    if not FileAccess.file_exists(file_path):
        return LoadResult.new([])

    var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
    if file == null:
        return LoadResult.new([], "could not open file (" + String.num_int64(FileAccess.get_open_error()) + "): " % [file_path])
    var parser: JSON = JSON.new()
    var res: int = parser.parse(file.get_as_text())
    file = null
    if res != OK:
        return LoadResult.new([], "'%s' could not parse: '%s'" % [file_path, parser.get_error_message()])
    if not "components" in parser.data:
        return LoadResult.new([], "'%s' does not have a 'components' field" % [file_path])

    var components: Array[Component] = []
    for raw: Dictionary in parser.data["components"]:
        components.append(Component.new().deserialize(raw))
    components = components
    return LoadResult.new(components)

static func set_license_data_filepath(path: String) -> void:
    ProjectSettings.set_setting(DATA_FILE, path)

static func get_license_data_filepath() -> String:
    # does not work due to https://github.com/godotengine/godot/issues/56598
    if ProjectSettings.has_setting(DATA_FILE):
        return ProjectSettings.get_setting(DATA_FILE)
    return "res://licenses.json"
