@tool
extends VBoxContainer

const IconDatabase := preload("res://addons/icon_explorer/internal/scripts/database.gd")
const Collection := preload("res://addons/icon_explorer/internal/scripts/collection.gd")

enum ButtonId {
    INSTALL,
    REMOVE,
    OPEN_DIR,
    WEB
}

@export var _check_update_button: Button
@export var _check_progress_bar: ProgressBar
@export var _tree: Tree

var db: IconDatabase:
    set = set_db

var _http_request: HTTPRequest
var _processing: int = -1
var _process_spinner_frame: int
var _process_spinner_msec: float
var _update_thread: Thread

func set_db(db_: IconDatabase) -> void:
    if db != null:
        db.load_finished.disconnect(self._on_processing_finished)
        db.collection_installed.disconnect(self._on_processing_finished)
        db.collection_removed.disconnect(self._on_processing_finished)
    db = db_
    db.load_finished.connect(self._on_processing_finished)
    db.collection_installed.connect(self._on_processing_finished)
    db.collection_removed.connect(self._on_processing_finished)
    self.update()

enum Column {
    INSTALLED,
    NAME,
    VERSION,
    LATEST_VERSION,
    LICENSE,
    WEB,
    ACTIONS,
    COLUMN_COUNT
}

func _ready() -> void:
    self._tree.clip_contents = false
    self._tree.columns = Column.COLUMN_COUNT
    #self._tree.set_column_title(Column.INSTALLED, "Installed")
    self._tree.set_column_title(Column.NAME, "Collection")
    self._tree.set_column_title(Column.VERSION, "Version")
    self._tree.set_column_title(Column.LATEST_VERSION, "Latest Version")
    self._tree.set_column_title(Column.LICENSE, "License")
    self._tree.set_column_title(Column.WEB, "Web")
    self._tree.set_column_title(Column.ACTIONS, "Actions")
    self._tree.set_column_expand(Column.INSTALLED, false)
    self._tree.set_column_expand(Column.NAME, true)
    self._tree.set_column_expand(Column.VERSION, true)
    self._tree.set_column_expand(Column.LATEST_VERSION, true)
    self._tree.set_column_expand(Column.LICENSE, true)
    self._tree.set_column_expand(Column.WEB, false)
    self._tree.set_column_expand(Column.ACTIONS, false)
    self._tree.button_clicked.connect(self._on_button_clicked)
    self._check_update_button.pressed.connect(self._check_for_updates)

    if Engine.is_editor_hint():
        ProjectSettings.settings_changed.connect(self.update)
    self.update()

func update() -> void:
    if !self.is_node_ready() || self.db == null:
        return
    self._tree.clear()
    self._tree.create_item()
    for coll: Collection in self.db.collections():
        var item: TreeItem = self._tree.create_item()
        item.set_metadata(Column.INSTALLED, coll)
        item.set_text(Column.NAME, coll.name)
        item.set_text(Column.VERSION, coll.version)
        item.set_text(Column.LATEST_VERSION, coll.latest_version)
        item.set_text(Column.LICENSE, coll.license)
        item.set_text_alignment(Column.INSTALLED, HORIZONTAL_ALIGNMENT_CENTER)
        item.set_text_alignment(Column.WEB, HORIZONTAL_ALIGNMENT_CENTER)
        item.add_button(Column.WEB, self.get_theme_icon(&"ExternalLink", &"EditorIcons"), ButtonId.WEB, coll.web == "", "Open in Browser")
        var is_processed: bool = self._processing == coll.id()
        if is_processed:
            pass
        elif coll.version != "" && coll.latest_version != "" && coll.latest_version > coll.version:
            item.set_icon(Column.INSTALLED, self.get_theme_icon(&"StatusWarning", &"EditorIcons"))
            item.set_tooltip_text(Column.INSTALLED, "Update Available")
        elif coll.is_installed():
            item.set_icon(Column.INSTALLED, self.get_theme_icon(&"StatusSuccess", &"EditorIcons"))
            item.set_tooltip_text(Column.INSTALLED, "Installed")
        else:
            item.set_icon(Column.INSTALLED, self.get_theme_icon(&"Node", &"EditorIcons"))
            item.set_tooltip_text(Column.INSTALLED, "Not Installed")

        var is_one_processed: bool = self._processing != -1
        if coll.is_installed():
            item.add_button(Column.ACTIONS, self.get_theme_icon(&"Reload", &"EditorIcons"), ButtonId.INSTALL, is_one_processed || coll.latest_version == "" || coll.latest_version <= coll.version, "Update")
        else:
            item.add_button(Column.ACTIONS, self.get_theme_icon(&"AssetLib", &"EditorIcons"), ButtonId.INSTALL, is_one_processed, "Install")
        item.add_button(Column.ACTIONS, self.get_theme_icon(&"Remove", &"EditorIcons"), ButtonId.REMOVE, is_one_processed || !coll.is_installed(), "Remove")
        item.add_button(Column.ACTIONS, self.get_theme_icon(&"Filesystem", &"EditorIcons"), ButtonId.OPEN_DIR, !coll.is_installed(), "Show in File Explorer")

func _check_for_updates() -> void:
    if self._update_thread != null && self._update_thread.is_alive():
        return
    if self._update_thread != null:
        self._update_thread.wait_to_finish()

    self._check_update_button.disabled = true
    self._check_progress_bar.max_value = self.db.collections().size()
    self._check_progress_bar.value = 0
    self._check_progress_bar.visible = true
    self._update_thread = Thread.new()
    var http: HTTPRequest = HTTPRequest.new()
    self.add_child(http)
    self._update_thread.start(self._update_check.bind(http))

# thread function
func _update_check(http: HTTPRequest) -> void:
    var upd := func upd() -> void: self._check_progress_bar.value += 1
    for coll: Collection in self.db.collections():
        coll.update_latest_version(http)
        upd.call_deferred()
    http.queue_free.call_deferred()
    self._update_check_done.call_deferred()

func _update_check_done() -> void:
    self._check_update_button.disabled = false
    self._check_progress_bar.visible = false
    self.update()

func _process(delta: float) -> void:
    self._process_spinner_msec += delta
    if self._process_spinner_msec > 0.2:
        self._process_spinner_msec = fmod(self._process_spinner_msec, 0.2)
        self._process_spinner_frame = (self._process_spinner_frame + 1) % 8
        if self._processing != -1:
            for item: TreeItem in self._tree.get_root().get_children():
                if (item.get_metadata(Column.INSTALLED) as Collection).id() == self._processing:
                    item.set_icon(Column.INSTALLED, self.get_theme_icon("Progress" + str(self._process_spinner_frame + 1), &"EditorIcons"))

func _gen_progress_texture() -> Array[Texture2D]:
    var anim: Array[Texture2D] = []
    for idx: int in range(8):
        anim.append(self.get_theme_icon("Progress" + str(idx + 1), &"EditorIcons"))
    return anim

func _on_button_clicked(item: TreeItem, _column: int, id: int, _mouse_button_index: int) -> void:
    var coll: Collection = item.get_metadata(0)
    match id:
        ButtonId.INSTALL:
            self._processing = coll.id()
            # lock buttons
            self.update()
            if self._http_request != null:
                self._http_request.queue_free()
            self._http_request = HTTPRequest.new()
            self._http_request.use_threads = true
            self._http_request.download_chunk_size = 4 * 65536
            self.add_child(self._http_request, true)
            self.db.install(coll, self._http_request, "")
        ButtonId.REMOVE:
            self._processing = coll.id()
            # lock buttons
            self.update()
            self.db.remove(coll)
        ButtonId.OPEN_DIR:
            OS.shell_show_in_file_manager(ProjectSettings.globalize_path(coll.icon_directory()))
        ButtonId.WEB:
            OS.shell_open(coll.web)

func _on_processing_finished(_id: int = 0, _status: Error = OK) -> void:
    self._processing = -1
    self.update()
