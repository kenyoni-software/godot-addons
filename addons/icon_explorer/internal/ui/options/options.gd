@tool
extends PanelContainer

const IconDatabase := preload("res://addons/icon_explorer/internal/scripts/database.gd")
const Collection := preload("res://addons/icon_explorer/internal/scripts/collection.gd")
const CollectionManagement := preload("res://addons/icon_explorer/internal/ui/options/collection_management.gd")

@export var _load_on_startup: CheckBox
@export var _show_main_screen: CheckBox
@export var _reload_current_project: Label
@export var _collection_management: CollectionManagement
@export var _options_panel: PanelContainer
@export var _options_label: Label
@export var _collections_panel: PanelContainer
@export var _collections_label: Label

func set_db(db: IconDatabase) -> void:
    self._collection_management.db = db

func _ready() -> void:
    if Engine.is_editor_hint():
        self._options_label.add_theme_font_override(&"font", self.get_theme_font(&"title", &"EditorFonts"))
        self._collections_label.add_theme_font_override(&"font", self.get_theme_font(&"title", &"EditorFonts"))
        self.add_theme_stylebox_override(&"panel", self.get_theme_stylebox(&"Background", &"EditorStyles"))
        self._collections_panel.add_theme_stylebox_override(&"panel", self.get_theme_stylebox(&"PanelForeground", &"EditorStyles"))
        self._options_panel.add_theme_stylebox_override(&"panel", self.get_theme_stylebox(&"PanelForeground", &"EditorStyles"))
        self._reload_current_project.add_theme_color_override(&"font_color", self.get_theme_color(&"warning_color", &"Editor"))

    self._load_on_startup.toggled.connect(self._on_startup_changed)
    self._show_main_screen.toggled.connect(self._on_show_main_screen_changed)

    if Engine.is_editor_hint():
        ProjectSettings.settings_changed.connect(self.update)
    self.update()

func update() -> void:
    self._load_on_startup.set_pressed_no_signal(ProjectSettings.get_setting("plugins/icon_explorer/load_on_startup", false) as bool)
    self._show_main_screen.set_pressed_no_signal(ProjectSettings.get_setting("plugins/icon_explorer/show_main_screen", true) as bool)

func _on_startup_changed(toggled: bool) -> void:
    ProjectSettings.set_setting("plugins/icon_explorer/load_on_startup", toggled)

func _on_show_main_screen_changed(toggled: bool) -> void:
    ProjectSettings.set_setting("plugins/icon_explorer/show_main_screen", toggled)
    self._reload_current_project.visible = true
