@tool
extends MarginContainer

@export var _reload_button: CheckButton
@export var _option_button: OptionButton

## Plugin directory path
var _last_selection: String = ""

func _ready() -> void:
    self._option_button.item_selected.connect(func(idx: int) -> void:
        self._last_selection = self._option_button.get_item_metadata(idx)
        self._update_button_bar()
    )
    self._reload_button.toggled.connect(func(toggled: bool) -> void:
        EditorInterface.set_plugin_enabled(self._last_selection.path_join("plugin.cfg"), toggled)
        self._reload_plugin_list()
    )

    EditorInterface.get_resource_filesystem().filesystem_changed.connect(self._reload_plugin_list)
    ProjectSettings.settings_changed.connect(self._on_project_settings_changed)
    self._reload_plugin_list()

func _update_button_bar() -> void:
    if self._last_selection != "":
        self._reload_button.set_pressed_no_signal(EditorInterface.is_plugin_enabled(self._last_selection.path_join("plugin.cfg")))
        self._option_button.icon = null
    self._reload_button.disabled = self._last_selection == ""

func _reload_plugin_list() -> void:
    self._option_button.clear()
    self._scan_plugins("res://addons/")
    if self._last_selection == "" && self._option_button.get_item_count() > 0:
        self._last_selection = self._option_button.get_item_metadata(0)
    self._update_button_bar()

## Scans for plugins recursively
func _scan_plugins(path: String) -> void:
    for dir: String in DirAccess.get_directories_at(path):
        self._add_plugin_to_list(path.path_join(dir))
        self._scan_plugins(path.path_join(dir))

func _add_plugin_to_list(plugin_path: String) -> void:
    # ignore the current plugin
    if plugin_path == "res://addons/kenyoni/plugin_reloader":
        return

    var cfg_path: String = plugin_path.path_join("plugin.cfg")
    if !FileAccess.file_exists(cfg_path):
        return

    var plugin_cfg: ConfigFile = ConfigFile.new()
    plugin_cfg.load(cfg_path)
    var plugin_name: String = plugin_cfg.get_value("plugin", "name", plugin_path.trim_prefix("res://addons/"))
    self._option_button.add_item(plugin_name)
    var idx: int = self._option_button.get_item_count() - 1
    self._option_button.set_item_metadata(idx, plugin_path)
    self._option_button.set_item_tooltip(idx, plugin_path + "/")
    if EditorInterface.is_plugin_enabled(cfg_path):
        self._option_button.set_item_icon(idx, self.get_theme_icon(&"TileChecked", &"EditorIcons"))
    else:
        self._option_button.set_item_icon(idx, self.get_theme_icon(&"TileUnchecked", &"EditorIcons"))
    if plugin_path == self._last_selection:
        self._option_button.select(idx)

func _on_project_settings_changed() -> void:
    for idx: int in range(self._option_button.get_item_count()):
        var plugin_path: String = self._option_button.get_item_metadata(idx)
        if EditorInterface.is_plugin_enabled(plugin_path.path_join("plugin.cfg")):
            self._option_button.set_item_icon(idx, self.get_theme_icon(&"TileChecked", &"EditorIcons"))
        else:
            self._option_button.set_item_icon(idx, self.get_theme_icon(&"TileUnchecked", &"EditorIcons"))
    self._reload_button.button_pressed = EditorInterface.is_plugin_enabled(self._last_selection.path_join("plugin.cfg"))
