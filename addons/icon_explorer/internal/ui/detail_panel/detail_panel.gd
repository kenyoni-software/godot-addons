@tool
extends PanelContainer

const Toolbar := preload("res://addons/icon_explorer/internal/ui/detail_panel/toolbar.gd")

const Collection := preload("res://addons/icon_explorer/internal/scripts/collection.gd")
const Icon := preload("res://addons/icon_explorer/internal/scripts/icon.gd")
const TextField := preload("res://addons/icon_explorer/internal/ui/detail_panel/text_field.gd")

@export var _detail_container: VBoxContainer
@export var _hint_container: CenterContainer
@export var _toolbar_path: NodePath
@onready var _toolbar: Toolbar = self.get_node(self._toolbar_path)
@export var _detail_tabs: TabContainer

@export var _icon: TextureRect
@export var _preview_background: TextureRect
@export var _preview_panel: PanelContainer
@export var _name: Label
@export var _collection: Label
@export var _size: Label

@export var _toolbar_panel: PanelContainer

var preview_size: int = 64:
    set = set_preview_size

var preview_color: Color = Color.WHITE:
    set = set_preview_color

var _cur_icon: Icon

func set_preview_size(new_size: int) -> void:
    preview_size = new_size
    if self._icon != null:
        self._preview_panel.custom_minimum_size = Vector2(0, new_size)
    #if self._preview_background != null:
        #self._preview_background.texture = gen_checkboard_texture(new_size, 8)

func set_preview_color(new_color: Color) -> void:
    preview_color = new_color
    if self._icon != null:
        self._icon.self_modulate = new_color

static func gen_checkboard_texture(size: int, check_size: int) -> Texture2D:
    var img: Image = Image.create(size, size, false, Image.FORMAT_RGBA8)
    var white: Color = Color(1, 1, 1, 0.2)
    var black: Color = Color(0, 0, 0, 0.2)
    for x: int in range(size):
        for y: int in range(size):
            if (int(x / check_size) % 2 + int(y / check_size) % 2) % 2 == 0:
                img.set_pixel(x, y, white)
            else:
                img.set_pixel(x, y, black)
    return ImageTexture.create_from_image(img)

func _ready() -> void:
    if Engine.is_editor_hint():
        self._toolbar_panel.add_theme_stylebox_override(&"panel", self.get_theme_stylebox(&"LaunchPadNormal", &"EditorStyles"))
    self._toolbar.save_pressed.connect(self._on_save_pressed.bind(false))
    self._toolbar.save_colored_pressed.connect(self._on_save_pressed.bind(true))
    self._icon.self_modulate = self.preview_color
    self.display(null)

func display(icon: Icon) -> void:
    self._cur_icon = icon
    
    self._detail_container.visible = icon != null
    self._hint_container.visible = icon == null
    if icon == null:
        return

    self._collection.text = icon.collection.name
    self._name.text = icon.name
    self._icon.texture = icon.texture
    self._size.text = "%dx%d" % [
        icon.texture.get_size().x / Collection.TEXTURE_SIZE * icon.collection.svg_size,
        icon.texture.get_size().y / Collection.TEXTURE_SIZE * icon.collection.svg_size
    ]
    
    self._detail_tabs.current_tab = icon.collection.id()
    self._detail_tabs.get_child(icon.collection.id()).display(icon)

func _on_save_pressed(colored: bool) -> void:
    if Engine.is_editor_hint():
        var dialog: EditorFileDialog = EditorFileDialog.new()
        self.add_child(dialog)
        dialog.access = EditorFileDialog.ACCESS_RESOURCES
        dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
        dialog.current_file = self._cur_icon.name + ".svg"
        dialog.close_requested.connect(dialog.queue_free)
        dialog.file_selected.connect(self._on_filepath_selected.bind(colored))
        dialog.popup_centered_ratio(0.4)
    else:
        var dialog: FileDialog = FileDialog.new()
        self.add_child(dialog)
        dialog.access = FileDialog.ACCESS_FILESYSTEM
        dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
        dialog.current_file = self._cur_icon.name + ".svg"
        dialog.close_requested.connect(dialog.queue_free)
        dialog.file_selected.connect(self._on_filepath_selected.bind(colored))
        dialog.popup_centered_ratio(0.4)

func _on_filepath_selected(path: String, colored: bool) -> void:
    if colored:
        var buffer: String = FileAccess.get_file_as_string(self._cur_icon.icon_path)
        if buffer == "":
            push_warning("could not load '" + self._cur_icon.icon_path + "'")
            return
        buffer = self._cur_icon.collection.convert_icon_colored(buffer, self.preview_color.to_html(false))
        var writer: FileAccess = FileAccess.open(path, FileAccess.WRITE)
        if writer == null:
            writer = null
            push_warning("could not save '" + path + "'")
            return
        writer.store_string(buffer)
        writer = null
    else:
        var err: Error = DirAccess.copy_absolute(self._cur_icon.icon_path, path)
        if err != OK:
            push_error(err)
            return
    if Engine.is_editor_hint():
        EditorInterface.get_resource_filesystem().scan()
