extends "res://addons/icon_explorer/internal/scripts/collection.gd"

const IconMaterialDesign := preload("res://addons/icon_explorer/internal/ext/material_design/icon.gd")
const ZipExtractorThreaded := preload("res://addons/icon_explorer/internal/scripts/tools/zip_extractor_threaded.gd")

const _DOWNLOAD_FILE: String = "https://github.com/Templarian/MaterialDesign-SVG/archive/master.zip"

func _init() -> void:
    self.name = "Material Design"
    self.version = ""
    self.author = "Austin Andrews"
    self.license = "Apache 2.0"
    self.web = "https://github.com/Templarian/MaterialDesign-SVG"

# OVERRIDE
func color_icon(buffer: String, color: String) -> String:
    return '<svg fill="#' + color + '"' + buffer.substr(4)

# OVERRIDE
func load() -> Array:
    var parser: JSON = JSON.new()
    var res: int = parser.parse(FileAccess.get_file_as_string(self.directory().path_join("MaterialDesign-SVG-master/meta.json")))
    if res != OK:
        push_warning("could not parse MDI meta.json: '%s'", [parser.get_error_message()])
        return [[], PackedStringArray()]

    var icon_path: String = self.icon_directory()
    var icons: Array[Icon] = []
    var buffers: PackedStringArray = PackedStringArray()
    for item: Dictionary in parser.data:
        var icon: IconMaterialDesign = IconMaterialDesign.new()
        icon.collection = self
        icon.svg_size = Vector2i(24, 24)
        icon.colorable = true
        icon.name = item["name"]
        icon.icon_path = icon_path.path_join(icon.name + ".svg")

        icon.author = item.get("author", "")
        icon.version = item.get("version", "")
        icon.aliases = item.get("aliases", PackedStringArray())
        icon.tags = item.get("tags", PackedStringArray())
        icon.deprecated = item.get("deprecated", false)

        var buffer: String = FileAccess.get_file_as_string(icon.icon_path)
        if buffer == "":
            push_warning("could not load '" + icon.icon_path + "'")
            continue
        icons.append(icon)
        buffers.append(self.color_icon(buffer, "FFFFFF"))

    var parser_version: JSON = JSON.new()
    var res_version: int = parser_version.parse(FileAccess.get_file_as_string(self.directory().path_join("MaterialDesign-SVG-master/package.json")))
    if res_version != OK:
        push_warning("could not parse MDI package.json: '%s'", [parser_version.get_error_message()])
        return [[], PackedStringArray()]
    self.version = parser_version.data["version"]

    return [icons, buffers]

# OVERRIDE
func install(http: HTTPRequest, _version: String) -> Error:
    DirAccess.make_dir_recursive_absolute(self.directory())
    var zip_path: String = OS.get_temp_dir().path_join(self.name.validate_filename() + ".zip")
    http.download_file = zip_path
    var downloader: Io.Downloader = Io.Downloader.new(http)
    downloader.await_request(_DOWNLOAD_FILE)
    if downloader.result != HTTPRequest.RESULT_SUCCESS:
        return Error.FAILED

    var extractor: ZipExtractorThreaded = ZipExtractorThreaded.new()
    extractor.thread_count = maxi(OS.get_processor_count() / 2, 1)
    extractor.extract(zip_path, self.directory(), [
        "MaterialDesign-SVG-master/package.json",
        "MaterialDesign-SVG-master/svg/",
        "MaterialDesign-SVG-master/meta.json",
        "MaterialDesign-SVG-master/LICENSE",
    ])
    extractor.wait()
    if extractor.error() != Error.OK:
        return Error.FAILED
    DirAccess.remove_absolute(zip_path)
    return Error.OK

# OVERRIDE
func remove() -> Error:
    self.version = ""
    return super.remove()

# OVERRIDE
func update_latest_version(http: HTTPRequest) -> void:
    var downloader: Io.Downloader = Io.Downloader.new(http)
    downloader.await_request("https://raw.githubusercontent.com/Templarian/MaterialDesign-SVG/master/package.json")
    if downloader.result != HTTPRequest.RESULT_SUCCESS:
        return

    var parser_version: JSON = JSON.new()
    var res_version: int = parser_version.parse(downloader.body.get_string_from_utf8())
    if res_version != OK:
        push_warning("could get latest icon tabler version: '%s'", [parser_version.get_error_message()])
        return
    self.latest_version = parser_version.data["version"]

# OVERRIDE
func icon_directory() -> String:
    return self.directory().path_join("MaterialDesign-SVG-master/svg/")
