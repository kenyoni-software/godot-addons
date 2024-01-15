extends "res://addons/icon_explorer/internal/scripts/collection.gd"

const IconTabler := preload("res://addons/icon_explorer/internal/scripts/collections/icon_tabler.gd")
const ZipUnpacker := preload("res://addons/icon_explorer/internal/scripts/tools/zip_unpacker.gd")

const _DOWNLOAD_FILE: String = "https://github.com/tabler/tabler-icons/archive/master.zip"

func _init() -> void:
    self.name = "tabler Icons"
    self.version = ""
    self.author = "Paweł Kuna"
    self.license = "MIT"
    self.web = "https://github.com/tabler/tabler-icons"
    self.svg_size = 24.0

# OVERRIDE
func convert_icon_colored(buffer: String, color: String) -> String:
    return buffer.replace("currentColor", "#" + color)

# OVERRIDE
func load() -> Array:
    var parser_version: JSON = JSON.new()
    var res_version: int = parser_version.parse(FileAccess.get_file_as_string(self.directory().path_join("tabler-icons-master/package.json")))
    if res_version != OK:
        push_warning("could not parse tabler icons package.json: '%s'", [parser_version.get_error_message()])
        return [[], PackedStringArray()]
    self.version = parser_version.data["version"]

    var parser: JSON = JSON.new()
    var res: int = parser.parse(FileAccess.get_file_as_string(self.directory().path_join("tabler-icons-master/tags.json")))
    if res != OK:
        push_warning("could not parse tabler icons tags.json: '%s'", [parser.get_error_message()])
        return [[], PackedStringArray()]

    var icon_path: String = self.icon_directory()
    var icons: Array[Icon] = []
    var buffers: PackedStringArray = PackedStringArray()
    for item: Dictionary in parser.data.values():
        var icon: IconTabler = IconTabler.new()
        icon.collection = self
        icon.name = item["name"]
        icon.icon_path = icon_path.path_join(icon.name + ".svg")

        icon.category = item.get("category", "")
        icon.tags = item.get("tags", PackedStringArray())
        icon.version = item.get("version", "")

        var buffer: String = FileAccess.get_file_as_string(icon.icon_path)
        if buffer == "":
            push_warning("could not load '" + icon.icon_path + "'")
            continue
        icons.append(icon)
        buffers.append(self.convert_icon_colored(buffer, "FFFFFF"))
    return [icons, buffers]

# OVERRIDE
func install(http: HTTPRequest, _version: String) -> Error:
    DirAccess.make_dir_recursive_absolute(self.directory())
    var zip_path: String = self.directory().path_join("icons.zip")
    http.download_file = zip_path
    var downloader: Io.FileDownloader = Io.FileDownloader.new(http)
    downloader.request.bind(_DOWNLOAD_FILE).call_deferred()

    downloader.wait()
    if downloader.result != HTTPRequest.RESULT_SUCCESS:
        return Error.FAILED

    var unzipper: ZipUnpacker = ZipUnpacker.new(zip_path, self.directory(), [
        "tabler-icons-master/package.json",
        "tabler-icons-master/icons/",
        "tabler-icons-master/tags.json",
        "tabler-icons-master/LICENSE",
    ])
    if !unzipper.unpack_mt(maxi(OS.get_processor_count() / 2, 1)):
        return Error.FAILED
    DirAccess.remove_absolute(zip_path)
    return Error.OK

# OVERRIDE
func remove() -> Error:
    self.version = ""
    return super.remove()

# OVERRIDE
func icon_directory() -> String:
    return self.directory().path_join("tabler-icons-master/icons/")
