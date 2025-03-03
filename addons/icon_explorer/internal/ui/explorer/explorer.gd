@tool
extends PanelContainer

const Collection := preload("res://addons/icon_explorer/internal/scripts/collection.gd")
const FilterOptions := preload("res://addons/icon_explorer/internal/ui/explorer/filter_options.gd")
const Icon := preload("res://addons/icon_explorer/internal/scripts/icon.gd")
const IconDatabase := preload("res://addons/icon_explorer/internal/scripts/database.gd")
const DetailPanel := preload("res://addons/icon_explorer/internal/ui/detail_panel/detail_panel.gd")

const Options := preload("res://addons/icon_explorer/internal/ui/options/options.gd")

@export var _filter_icon: TextureRect
@export var _filter: LineEdit
@export var _filter_options: FilterOptions
@export var _preview_color: ColorPickerButton
@export var _preview_size: HSlider
@export var _icon_list: ItemList
@export var _options_button: Button
@export var _options_popup: Window
@export var _options: Options

@export var _progress_bar: ProgressBar

@export var _detail_panel: DetailPanel

@export var _toolbar_panel: PanelContainer
@export var _preview_options_panel: PanelContainer

var _db: IconDatabase

# timer which starts after filter change and will fire the update
# is updated on each input again to not update the list on each change but wait a short time
var _update_timer: Timer

func _ready() -> void:
    if Engine.is_editor_hint():
        self.add_theme_stylebox_override(&"panel", self.get_theme_stylebox(&"Background", &"EditorStyles"))
        self._toolbar_panel.add_theme_stylebox_override(&"panel", self.get_theme_stylebox(&"PanelForeground", &"EditorStyles"))
        self._preview_options_panel.add_theme_stylebox_override(&"panel", self.get_theme_stylebox(&"LaunchPadNormal", &"EditorStyles"))

    self._update_timer = Timer.new()
    self._update_timer.one_shot = true
    self._update_timer.timeout.connect(self.update)
    self.add_child(self._update_timer, true)
    self.get_viewport().gui_embed_subwindows = false
    self._filter_icon.texture = self.get_theme_icon(&"Search", &"EditorIcons")
    self._filter_options.icon = self.get_theme_icon(&"AnimationFilter", &"EditorIcons")
    self._filter_options.options_changed.connect(self.update)
    self._icon_list.item_selected.connect(self._on_icon_selected)
    self._filter.text_changed.connect(self._on_filter_changed)
    self._filter.text_submitted.connect(self._on_filter_submitted)
    self._preview_color.popup_closed.connect(self._update_preview_color)
    self._update_preview_size(ProjectSettings.get_setting("plugins/icon_explorer/preview_size_exp") as float)
    if Engine.is_editor_hint():
        ProjectSettings.settings_changed.connect(
        func() -> void:
            self._update_preview_size(ProjectSettings.get_setting("plugins/icon_explorer/preview_size_exp") as float)
    )
    self._preview_size.value_changed.connect(self._on_preview_size_changed)
    self._detail_panel.preview_color = self._preview_color.color

    self._options_button.icon = self.get_theme_icon(&"Tools", &"EditorIcons")
    self._options_button.pressed.connect(self._on_option_pressed)
    self.focus_entered.connect(self._on_focus_entered)

    self.set_process(false)
    if !Engine.is_editor_hint():
        self.set_icon_db(IconDatabase.new(self.get_tree()))
        self._db.load()

func _process(_delta: float) -> void:
    var progress: float = self._db.load_progress()
    self._progress_bar.indeterminate = progress <= 0.0
    self._progress_bar.value = progress

func set_icon_db(db: IconDatabase) -> void:
    if self._db != null:
        self._db.load_started.disconnect(self._on_icon_database_load_started)
        self._db.load_finished.disconnect(self._on_icon_database_load_finished)
        self._db.collection_installed.disconnect(self._on_database_changed)
        self._db.collection_removed.disconnect(self._on_database_changed)

    self._db = db
    self._db.load_started.connect(self._on_icon_database_load_started)
    self._db.load_finished.connect(self._on_icon_database_load_finished)
    self._db.collection_installed.connect(self._on_database_changed)
    self._db.collection_removed.connect(self._on_database_changed)
    self._options.set_db(self._db)

func update() -> void:
    var filter: String = self._filter.text.to_lower()
    self._clear()

    var icons: Array[Icon] = self._db.icons().duplicate()
    var filter_popup: PopupMenu = self._filter_options.get_popup()
    for icon in icons:
        if !filter_popup.is_item_checked(filter_popup.get_item_index(icon.collection.id())):
            icon.sort_priority = 0
            continue
        if filter == "":
            icon.sort_priority = 5
        else:
            icon.sort_priority = icon.match(filter)
    icons.sort_custom(Icon.compare)
    var color: Color = self._preview_color.color
    for icon in icons:
        if icon.sort_priority == 0:
            continue
        var idx: int = self._icon_list.add_item(icon.name, icon.texture)
        self._icon_list.set_item_tooltip(idx, icon.collection.name)
        self._icon_list.set_item_metadata(idx, icon)
        if icon.colorable:
            self._icon_list.set_item_icon_modulate(idx, color)
        else:
            self._icon_list.set_item_icon_modulate(idx, Color.WHITE)
    self._icon_list.get_v_scroll_bar().value = 0

func _clear() -> void:
    self._icon_list.clear()
    self._detail_panel.display(null)

func _update_preview_color() -> void:
    var color: Color = self._preview_color.color
    self._detail_panel.preview_color = color
    for idx: int in range(self._icon_list.item_count):
        if (self._icon_list.get_item_metadata(idx) as Icon).colorable:
            self._icon_list.set_item_icon_modulate(idx, color)
        else:
            self._icon_list.set_item_icon_modulate(idx, Color.WHITE)

func _on_preview_size_changed(expo: float) -> void:
    self._update_preview_size(expo)
    ProjectSettings.set_setting("plugins/icon_explorer/preview_size_exp", expo)

func _update_preview_size(expo: float) -> void:
    var icon_size: int = int(pow(2.0, expo))
    self._icon_list.fixed_icon_size = Vector2i(icon_size, icon_size)
    self._icon_list.fixed_column_width = 2 * icon_size
    self._detail_panel.preview_size = icon_size

func _on_database_changed(_id: int, status: Error) -> void:
    var filter_popup: PopupMenu = self._filter_options.get_popup()
    filter_popup.clear()
    for coll: Collection in self._db.installed_collections():
        filter_popup.add_check_item(coll.name, int(coll.id()))
    for idx: int in range(filter_popup.item_count):
        filter_popup.set_item_checked(idx, true)
    self._filter_options.disabled = filter_popup.item_count == 0
    if status == Error.OK:
        self.update()

func _on_icon_database_load_started() -> void:
    self.set_process(true)

func _on_icon_database_load_finished() -> void:
    self.set_process(false)
    self._progress_bar.value = 100.0
    self._progress_bar.visible = false
    self._filter.editable = true
    self._options_button.disabled = false

    var filter_popup: PopupMenu = self._filter_options.get_popup()
    filter_popup.clear()
    for coll: Collection in self._db.installed_collections():
        filter_popup.add_check_item(coll.name, int(coll.id()))
    for idx: int in range(filter_popup.item_count):
        filter_popup.set_item_checked(idx, true)
    self._filter_options.disabled = filter_popup.item_count == 0
    self.update()

func _on_icon_selected(idx: int) -> void:
    self._detail_panel.display(self._icon_list.get_item_metadata(idx) as Icon)

func _on_filter_changed(_text: String) -> void:
    self._update_timer.start(0.3)

func _on_filter_submitted(_text: String) -> void:
    self._update_timer.start(0.05)

func _on_option_pressed() -> void:
    self._options_popup.popup_centered_ratio(0.35)

func _on_focus_entered() -> void:
    self._filter.grab_focus()
    self._filter.select_all()
