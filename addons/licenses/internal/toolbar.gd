@tool
extends HBoxContainer

const Licenses := preload("res://addons/licenses/licenses.gd")
const Component := preload("res://addons/licenses/component.gd")
const ComponentTree := preload("res://addons/licenses/internal/components_tree.gd")

signal add_component(comp: Component)
signal show_engine_components(show: bool)

@export var _menu_button: Button = null
@export var _add_button: Button = null

var _menu: PopupMenu
var _add_menu: PopupMenu
var _add_plugin_menu: PopupMenu
var _add_engine_menu: PopupMenu

func _ready() -> void:
    self._menu_button.icon = self.get_theme_icon(&"GuiTabMenuHl", &"EditorIcons")
    self._menu_button.pressed.connect(self._on_menu_pressed)
    self._add_button.icon = self.get_theme_icon(&"Add", &"EditorIcons")
    self._add_button.pressed.connect(self._on_add_pressed)

    self._menu = PopupMenu.new()
    self._menu.add_check_item("Show Engine Components", 0)
    self._menu.id_pressed.connect(self._on_menu_id_pressed)
    self.add_child(self._menu)

    self._add_menu = PopupMenu.new()
    self._add_menu.add_item("New Component", 0)
    self._add_menu.set_item_icon(0, get_theme_icon(&"New", &"EditorIcons"))
    self._add_menu.add_submenu_item("Generate from Plugin", "menu_plugin", 1)
    self._add_menu.set_item_icon(1, get_theme_icon(&"EditorPlugin", &"EditorIcons"))
    self._add_menu.add_submenu_item("Generate from Engine", "menu_engine", 2)
    self._add_menu.set_item_icon(2, get_theme_icon(&"Godot", &"EditorIcons"))
    self._add_menu.id_pressed.connect(self._on_add_id_pressed)
    self.add_child(self._add_menu)

    self._create_plugin_menu_items()
    self._create_engine_menu_items()

# get plugin config as dictionary
func _get_plugin_config(path: String) -> Dictionary:
    var config: ConfigFile = ConfigFile.new()
    var err: int = config.load(path)
    if err != OK:
        push_warning("Could not load " + path)
        return {}

    var cfg_data: Dictionary = {}
    for section: String in config.get_sections():
        var section_data: Dictionary = {}
        for key: String in config.get_section_keys(section):
            section_data[key] = config.get_value(section, key)
        cfg_data[section] = section_data
    return cfg_data

func _create_engine_menu_items() -> void:
    self._add_engine_menu = PopupMenu.new()
    self._add_engine_menu.id_pressed.connect(self._on_engine_add_id_pressed)
    self._add_engine_menu.name = "menu_engine"
    self._add_menu.add_child(self._add_engine_menu)

    var idx: int = 0
    for info: Dictionary in Engine.get_copyright_info():
        self._add_engine_menu.add_item(info["name"])
        self._add_engine_menu.set_item_metadata(idx, info["name"])
        idx = idx + 1

    # set max size to ~10 items
    var min_size: Vector2 = self._add_engine_menu.get_contents_minimum_size()
    min_size.y = 280
    self._add_engine_menu.max_size = min_size

func _create_plugin_menu_items() -> void:
    self._add_plugin_menu = PopupMenu.new()
    self._add_plugin_menu.id_pressed.connect(self._on_plugin_add_id_pressed)
    self._add_plugin_menu.name = "menu_plugin"
    self._add_menu.add_child(self._add_plugin_menu)

    var dir: DirAccess = DirAccess.open("res://addons/")
    if dir == null:
        return

    dir.list_dir_begin()
    var elem: String = dir.get_next()
    var idx: int = 0
    while (not elem.is_empty()):
        if dir.current_is_dir():
            var path: String = "res://addons/".path_join(elem).path_join("/plugin.cfg")
            var cfg: Dictionary = self._get_plugin_config(path)
            var name: String = cfg.get("plugin", {}).get("name", "")
            if name != "":
                self._add_plugin_menu.add_item(name)
                self._add_plugin_menu.set_item_metadata(idx, path)
                idx = idx + 1
        elem = dir.get_next()
    dir.list_dir_end()
    dir = null
    # set max size to ~10 items
    var min_size: Vector2 = self._add_plugin_menu.get_contents_minimum_size()
    min_size.y = 284
    self._add_plugin_menu.max_size = min_size

func _on_add_pressed() -> void:
    self._add_menu.popup_on_parent(Rect2(self._add_button.global_position + Vector2(0.0, self._add_button.size.y), self._add_menu.get_contents_minimum_size()))

func _on_menu_pressed() -> void:
    self._menu.popup_on_parent(Rect2(self._menu_button.global_position + Vector2(0.0, self._menu_button.size.y), self._menu.get_contents_minimum_size()))

# add license entry based on engine entry
func _on_engine_add_id_pressed(id: int) -> void:
    var component: Component = Licenses.get_engine_component(self._add_engine_menu.get_item_metadata(id))
    if component == null:
        return
    component.readonly = false
    self.add_component.emit(component)

# add component entry based on plugin cfg
func _on_plugin_add_id_pressed(id: int) -> void:
    var cfg: Dictionary = self._get_plugin_config(self._add_plugin_menu.get_item_metadata(id))
    var component: Component = Component.new()
    component.name = cfg["plugin"]["name"]
    component.description = cfg["plugin"].get("description", "")
    component.copyright.append(cfg["plugin"].get("author", ""))
    component.version = cfg["plugin"].get("version", "")
    component.paths.append(self._add_plugin_menu.get_item_metadata(id).get_base_dir())
    self.add_component.emit(component)

func _on_menu_id_pressed(id: int) -> void:
    match id:
        0:
            self._menu.toggle_item_checked(0)
            self.show_engine_components.emit(self._menu.is_item_checked(0))

func _on_add_id_pressed(id: int) -> void:
    match id:
        0:
            var component: Component = Component.new()
            self.add_component.emit(component)
