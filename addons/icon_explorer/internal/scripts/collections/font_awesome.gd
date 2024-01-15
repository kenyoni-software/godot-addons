extends "res://addons/icon_explorer/internal/scripts/collection.gd"

const IconFontAwesome := preload("res://addons/icon_explorer/internal/scripts/collections/icon_font_awesome.gd")
const ZipUnpacker := preload("res://addons/icon_explorer/internal/scripts/tools/zip_unpacker.gd")

const _DOWNLOAD_FILE: String = "https://github.com/FortAwesome/Font-Awesome/archive/6.x.zip"

func _init() -> void:
    self.name = "Font Awesome 6"
    self.version = ""
    self.author = "The Font Awesome Team"
    self.license = "CC BY 4.0"
    self.web = "https://github.com/FortAwesome/Font-Awesome"
    self.svg_size = 512.0

# OVERRIDE
func convert_icon_colored(buffer: String, color: String) -> String:
    return '<svg fill="#' + color + '"' + buffer.substr(4)

# OVERRIDE
func load() -> Array:
    var parser_version: JSON = JSON.new()
    var res_version: int = parser_version.parse(FileAccess.get_file_as_string(self.directory().path_join("Font-Awesome-6.x/js-packages/@fortawesome/fontawesome-free/package.json")))
    if res_version != OK:
        push_warning("could not parse font awesome package.json: '%s'", [parser_version.get_error_message()])
        return [[], PackedStringArray()]
    self.version = parser_version.data["version"]

    var meta_string: String = FileAccess.get_file_as_string(self.directory().path_join("Font-Awesome-6.x/metadata/icons.json"))
    var icons: Array[Icon] = []
    var buffers: PackedStringArray = PackedStringArray()
    var start_idx: int = meta_string.find("\n  \"")
    var parser: JSON = JSON.new()
    while start_idx > 0:
        var end_idx: int = meta_string.find("\n  \"", start_idx + 1)
        var meta: String
        if end_idx != -1:
            meta = "{" + meta_string.substr(start_idx, end_idx - start_idx - 1) + "}"
        else:
            meta = "{" + meta_string.substr(start_idx) + "}"
        start_idx = end_idx
        var res: int = parser.parse(meta)
        if res != OK:
            push_warning("could not parse font awesome meta: '%s'", [parser.get_error_message()])
            continue
        var icon_id: String = parser.data.keys()[0]
        var item: Dictionary = parser.data.values()[0]
        for style: String in item.get("styles", []):
            var icon: IconFontAwesome = IconFontAwesome.new()
            icon.collection = self
            icon.name = item["label"]
            icon.icon_path = self.icon_directory().path_join(style + "/" + icon_id + ".svg")

            icon.style = style
            icon.aliases = item.get("aliases", {}).get("names", PackedStringArray())
            icon.search_terms =  item.get("search", {}).get("terms", PackedStringArray())
            icons.append(icon)
            buffers.append(self.convert_icon_colored(item["svg"][style]["raw"], "FFFFFF"))

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
        "Font-Awesome-6.x/js-packages/@fortawesome/fontawesome-free/package.json",
        "Font-Awesome-6.x/svgs/",
        "Font-Awesome-6.x/metadata/icons.json",
        "Font-Awesome-6.x/LICENSE.txt",
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
    return self.directory().path_join("Font-Awesome-6.x/svgs/")
