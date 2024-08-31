@tool
extends MarginContainer

@export var _reload_button: CheckButton
@export var _option_button: OptionButton

var _last_selection: String = ""

func _ready() -> void:
    self._option_button.item_selected.connect(func(idx: int) -> void:
        self._last_selection = self._option_button.get_item_metadata(idx)
        self._update_button_bar()
    )
    self._reload_button.toggled.connect(func(toggled: bool) -> void:
        EditorInterface.set_plugin_enabled("res://addons/" + self._last_selection + "/plugin.cfg", toggled)
        self._reload_plugin_list()
    )

    EditorInterface.get_resource_filesystem().filesystem_changed.connect(self._reload_plugin_list)
    self._reload_plugin_list()

func _update_button_bar() -> void:
    if self._last_selection != "":
        self._reload_button.set_pressed_no_signal(EditorInterface.is_plugin_enabled("res://addons/" + self._last_selection + "/plugin.cfg"))
        self._option_button.icon = null
    self._reload_button.disabled = self._last_selection == ""

func _reload_plugin_list() -> void:
    self._option_button.clear()
    for dir: String in DirAccess.get_directories_at("res://addons/"):
        self._add_plugin_to_list(dir)
        # subfolder
        for sub_dir: String in DirAccess.get_directories_at("res://addons/" + dir):
            self._add_plugin_to_list(dir + "/" + sub_dir)

    if self._last_selection == "" && self._option_button.get_item_count() > 0:
        self._last_selection = self._option_button.get_item_metadata(0)
    self._update_button_bar()

func _add_plugin_to_list(plugin_id: String) -> void:
    # ignore the current plugin
    if plugin_id == "kenyoni/plugin_reloader":
        return

    var cfg_path: String = "res://addons/" + plugin_id + "/plugin.cfg"
    if !FileAccess.file_exists(cfg_path):
        return

    var plugin_cfg: ConfigFile = ConfigFile.new()
    plugin_cfg.load(cfg_path)
    var plugin_name: String = plugin_cfg.get_value("plugin", "name", plugin_id)
    self._option_button.add_item(plugin_name)
    var idx: int = self._option_button.get_item_count() - 1
    self._option_button.set_item_metadata(idx, plugin_id)
    self._option_button.set_item_tooltip(idx, "res://addons/" + plugin_id + "/")
    if EditorInterface.is_plugin_enabled(cfg_path):
        self._option_button.set_item_icon(idx, self.get_theme_icon(&"TileChecked", &"EditorIcons"))
    else:
        self._option_button.set_item_icon(idx, self.get_theme_icon(&"TileUnchecked", &"EditorIcons"))
    if plugin_id == self._last_selection:
        self._option_button.select(idx)
