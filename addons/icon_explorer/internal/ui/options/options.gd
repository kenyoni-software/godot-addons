@tool
extends PanelContainer

const IconDatabase := preload("res://addons/icon_explorer/internal/scripts/database.gd")
const Collection := preload("res://addons/icon_explorer/internal/scripts/collection.gd")

enum BUTTON_ID {
    INSTALL,
    REMOVE,
    OPEN_DIR,
    WEB
}

@export var _load_on_startup: CheckBox
@export var _collection_tree: Tree
@export var _options_panel: PanelContainer
@export var _options_label: Label
@export var _collections_panel: PanelContainer
@export var _collections_label: Label

var _http_request: HTTPRequest

var db: IconDatabase:
    set = set_db

var _processing: int = -1
var _process_spinner_frame: int
var _process_spinner_msec: float

func set_db(db_: IconDatabase) -> void:
    if db != null:
        db.collection_installed.disconnect(self._on_processing_finished)
        db.collection_removed.disconnect(self._on_processing_finished)
    db = db_
    db.collection_installed.connect(self._on_processing_finished)
    db.collection_removed.connect(self._on_processing_finished)
    self.update()

func _process(delta: float) -> void:
    self._process_spinner_msec += delta
    if self._process_spinner_msec > 0.2:
        self._process_spinner_msec = fmod(self._process_spinner_msec, 0.2)
        self._process_spinner_frame = (self._process_spinner_frame + 1) % 8
        if self._processing != -1:
            for item: TreeItem in _collection_tree.get_root().get_children():
                if (item.get_metadata(0) as Collection).id() == self._processing:
                    item.set_icon(0, self.get_theme_icon("Progress"+str(self._process_spinner_frame + 1), &"EditorIcons"))

func _ready() -> void:
    if Engine.is_editor_hint():
        self._options_label.add_theme_font_override(&"font", self.get_theme_font(&"title", &"EditorFonts"))
        self._collections_label.add_theme_font_override(&"font", self.get_theme_font(&"title", &"EditorFonts"))
        self.add_theme_stylebox_override(&"panel", self.get_theme_stylebox(&"Background", &"EditorStyles"))
        self._collections_panel.add_theme_stylebox_override(&"panel", self.get_theme_stylebox(&"PanelForeground", &"EditorStyles"))
        self._options_panel.add_theme_stylebox_override(&"panel", self.get_theme_stylebox(&"PanelForeground", &"EditorStyles"))

    self._load_on_startup.toggled.connect(self._on_startup_changed)

    self._collection_tree.columns = 6
    self._collection_tree.set_column_title(0, "Installed")
    self._collection_tree.set_column_title(1, "Collection")
    self._collection_tree.set_column_title(2, "Version")
    self._collection_tree.set_column_title(3, "License")
    self._collection_tree.set_column_title(4, "Web")
    self._collection_tree.set_column_title(5, "Actions")
    self._collection_tree.set_column_expand(0, false)
    self._collection_tree.set_column_expand(1, true)
    self._collection_tree.set_column_expand(2, true)
    self._collection_tree.set_column_expand(3, true)
    self._collection_tree.set_column_expand(4, false)
    self._collection_tree.set_column_expand(5, false)
    self._collection_tree.button_clicked.connect(self._on_button_clicked)

    if Engine.is_editor_hint():
        ProjectSettings.settings_changed.connect(self.update)

func update() -> void:
    self._load_on_startup.button_pressed = ProjectSettings.get_setting("plugins/icon_explorer/load_on_startup", false)

    self._collection_tree.clear()
    self._collection_tree.create_item()
    for coll: Collection in self.db.collections():
        var item: TreeItem = self._collection_tree.create_item()
        item.set_metadata(0, coll)
        item.set_text(1, coll.name)
        item.set_text(2, coll.version)
        item.set_text(3, coll.license)
        item.set_text_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)
        item.set_text_alignment(4, HORIZONTAL_ALIGNMENT_CENTER)
        item.add_button(4, self.get_theme_icon(&"ExternalLink", &"EditorIcons"), BUTTON_ID.WEB, coll.web == "", "Open in Browser")
        var is_processed: bool = self._processing == coll.id()
        if is_processed:
            pass
        elif coll.is_installed():
            item.set_icon(0, self.get_theme_icon(&"StatusSuccess", &"EditorIcons"))
        else:
            item.set_icon(0, self.get_theme_icon(&"Node", &"EditorIcons"))

        var is_one_processed: bool = self._processing != -1
        if coll.is_installed():
            item.add_button(5, self.get_theme_icon(&"Reload", &"EditorIcons"), BUTTON_ID.INSTALL, is_one_processed, "Update")
        else:
            item.add_button(5, self.get_theme_icon(&"AssetLib", &"EditorIcons"), BUTTON_ID.INSTALL, is_one_processed, "Install")
        item.add_button(5, self.get_theme_icon(&"Remove", &"EditorIcons"), BUTTON_ID.REMOVE, is_one_processed || !coll.is_installed(), "Remove")
        item.add_button(5, self.get_theme_icon(&"Filesystem", &"EditorIcons"), BUTTON_ID.OPEN_DIR, !coll.is_installed(), "Show in File Explorer")

func _gen_progress_texture() -> Array[Texture2D]:
    var anim: Array[Texture2D] = []
    for idx: int in range(8):
        anim.append(self.get_theme_icon("Progress"+str(idx + 1), &"EditorIcons"))
    return anim

func _on_startup_changed(toggled: bool) -> void:
    ProjectSettings.set_setting("plugins/icon_explorer/load_on_startup", toggled)

func _on_button_clicked(item: TreeItem, _column: int, id: int, _mouse_button_index: int) -> void:
    var coll: Collection = item.get_metadata(0)
    match id:
        BUTTON_ID.INSTALL:
            self._processing = coll.id()
            self.update()
            if self._http_request != null:
                self._http_request.queue_free()
            self._http_request = HTTPRequest.new()
            self.add_child(self._http_request, true)
            self.db.install(coll, self._http_request, "")
        BUTTON_ID.REMOVE:
            self._processing = coll.id()
            self.update()
            self.db.remove(coll)
        BUTTON_ID.OPEN_DIR:
            OS.shell_show_in_file_manager(coll.icon_directory())
        BUTTON_ID.WEB:
            OS.shell_open(coll.web)

func _on_processing_finished(id: int, status: Error) -> void:
    self._processing = -1
    self.update()
