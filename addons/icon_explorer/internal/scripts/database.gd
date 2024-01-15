extends RefCounted
## This class is not thread safe.
## Do not call install, remove or load at the same time.
## Any texture loading has to be done on the main thread: https://github.com/godotengine/godot/issues/86796

const Collection := preload("res://addons/icon_explorer/internal/scripts/collection.gd")
const CollectionBootstrap := preload("res://addons/icon_explorer/internal/scripts/collections/bootstrap.gd")
const CollectionFontAwesome := preload("res://addons/icon_explorer/internal/scripts/collections/font_awesome.gd")
const CollectionMaterialDesign := preload("res://addons/icon_explorer/internal/scripts/collections/material_design.gd")
const CollectionSimpleIcons := preload("res://addons/icon_explorer/internal/scripts/collections/simple_icons.gd")
const CollectionTabler := preload("res://addons/icon_explorer/internal/scripts/collections/tabler.gd")
const Icon := preload("res://addons/icon_explorer/internal/scripts/icon.gd")

signal collection_installed(id: int, status: Error)
signal collection_removed(id: int, status: Error)
## emitted after calling load()
signal loaded()

var _loaded_collections: Array[int] = []
var _collections: Array[Collection] = []
var _icons: Array[Icon] = []

## used to await next frame on texture loading
var _scene_tree: SceneTree
## no mutex required as loading is suspended while main thread runs
## as this progress is exclusively used in loading the textures
var _load_progress: float
var _processing_thread: Thread

func load_progress() -> float:
    return self._load_progress

func _init(scene_tree: SceneTree) -> void:
    self._scene_tree = scene_tree
    self.register(CollectionBootstrap.new())
    self.register(CollectionFontAwesome.new())
    self.register(CollectionMaterialDesign.new())
    self.register(CollectionSimpleIcons.new())
    self.register(CollectionTabler.new())

func _notification(what):
    if what == NOTIFICATION_PREDELETE:
        if self._processing_thread != null:
            self._processing_thread.wait_to_finish()

func collections() -> Array[Collection]:
    return self._collections

func get_collection(id: int) -> Collection:
    for coll: Collection in self._collections:
        if coll.id() == id:
            return coll

    return null

func installed_collections() -> Array[Collection]:
    return self._collections.filter(func(coll: Collection) -> bool: return coll.is_installed())

func icons() -> Array[Icon]:
    return self._icons

# register each collection only once
func register(coll: Collection) -> void:
    self._collections.append(coll)
    coll._id = self._collections.size() - 1

func install(coll: Collection, http: HTTPRequest, version: String) -> void:
    if self._processing_thread != null && self._processing_thread.is_alive():
        return
    if self._processing_thread != null:
        self._processing_thread.wait_to_finish()

    self._processing_thread = Thread.new()
    self._processing_thread.start(self._install.bind(coll, http, version))

# THREAD FUNCTION
func _install(coll: Collection, http: HTTPRequest, version: String) -> void:
    var status: Error = coll.install(http, version)
    if status != Error.OK:
        self._install_done.bind(coll.id(), status).call_deferred()
        return
    if self._loaded_collections.has(coll.id()):
        self._icons = self._icons.filter(func (icon: Icon) -> bool: return icon.collection.id() != coll.id())
    self._load()
    self._install_done.bind(coll.id(), status).call_deferred()

func _install_done(id: int, status: Error) -> void:
    if self._loaded_collections.has(id):
        self._icons = self._icons.filter(func (icon: Icon) -> bool: return icon.collection.id() != id)
        if !self._loaded_collections.has(id):
            self._loaded_collections.append(id)
    self.collection_installed.emit(id, status)

func remove(coll: Collection) -> void:
    if self._processing_thread != null && self._processing_thread.is_alive():
        return
    if self._processing_thread != null:
        self._processing_thread.wait_to_finish()

    self._processing_thread = Thread.new()
    self._processing_thread.start(self._remove.bind(coll))

# THREAD FUNCTION
func _remove(coll: Collection) -> void:
    var status: Error = coll.remove()
    self._remove_done.bind(coll.id(), status).call_deferred()

func _remove_done(id: int, status: Error) -> void:
    self._icons = self._icons.filter(func (icon: Icon) -> bool: return icon.collection.id() != id)
    self.collection_removed.emit(id, status)

func load() -> void:
    if self._processing_thread != null && self._processing_thread.is_alive():
        return
    if self._processing_thread != null:
        self._processing_thread.wait_to_finish()

    self._processing_thread = Thread.new()
    self._processing_thread.start(self._load)

# thread function
func _load() -> void:
    var loaded_icons: Array[Icon] = []
    var buffers: PackedStringArray = PackedStringArray()
    self._load_progress = 0.0
    for idx: int in range(self._collections.size()):
        var coll: Collection = self._collections[idx]
        if !self._loaded_collections.has(coll.id()) && coll.is_installed():
            var res: Array = coll.load()
            loaded_icons.append_array(res[0])
            buffers.append_array(res[1])
            self._loaded_collections.append(coll.id())
    self._load_done.bind(loaded_icons, buffers).call_deferred()

func _load_done(loaded_icons: Array[Icon], buffers: PackedStringArray) -> void:
    for idx: int in range(loaded_icons.size()):
        if idx % 50 == 0:
            self._load_progress = float(idx + 1) / loaded_icons.size() * 100.0
            await self._scene_tree.process_frame
        _load_texture(loaded_icons[idx], buffers[idx])
    self._icons.append_array(loaded_icons)
    self.loaded.emit()

static func _load_texture(icon: Icon, buffer: String) -> void:
    var img: Image = Image.new()
    # scale texture to 128
    var success: int = img.load_svg_from_string(buffer, Collection.TEXTURE_SIZE / icon.collection.svg_size)
    if success != OK:
        push_warning("could not load '" + icon.icon_path + "'")
        return
    img.fix_alpha_edges()
    icon.texture = ImageTexture.create_from_image(img)
