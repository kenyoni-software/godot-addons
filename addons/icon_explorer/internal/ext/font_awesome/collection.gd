extends "res://addons/icon_explorer/internal/scripts/collection.gd"

const IconFontAwesome := preload("res://addons/icon_explorer/internal/ext/font_awesome/icon.gd")
const ZipExtractorThreaded := preload("res://addons/icon_explorer/internal/scripts/tools/zip_extractor_threaded.gd")

const _DOWNLOAD_FILE: String = "https://github.com/FortAwesome/Font-Awesome/archive/6.x.zip"

func _init() -> void:
    self.name = "Font Awesome 6"
    self.version = ""
    self.author = "The Font Awesome Team"
    self.license = "CC BY 4.0"
    self.web = "https://github.com/FortAwesome/Font-Awesome"

# OVERRIDE
func color_icon(buffer: String, color: String) -> String:
    return '<svg fill="#' + color + '"' + buffer.substr(4)

# OVERRIDE
func load() -> Array:
    var parser: JSON = JSON.new()
    var res: int = parser.parse(FileAccess.get_file_as_string(self.directory().path_join("Font-Awesome-6.x/metadata/icons.json")))
    if res != OK:
        push_warning("could not parse font awesome meta: '%s'", [parser.get_error_message()])
        return [[], PackedStringArray()]

    var icons: Array[Icon] = []
    var buffers: PackedStringArray = PackedStringArray()
    for icon_id: String in parser.data:
        var item: Dictionary = parser.data[icon_id]
        for style: String in item.get("styles", []):
            var icon: IconFontAwesome = IconFontAwesome.new()
            icon.collection = self
            icon.svg_size = Vector2i(512, 512)
            icon.colorable = true
            icon.name = item["label"]
            icon.icon_path = self.icon_directory().path_join(style + "/" + icon_id + ".svg")

            icon.style = style
            icon.aliases = item.get("aliases", {}).get("names", PackedStringArray())
            icon.search_terms = item.get("search", {}).get("terms", PackedStringArray())
            icons.append(icon)
            buffers.append(self.color_icon(item["svg"][style]["raw"], "FFFFFF"))

    var parser_version: JSON = JSON.new()
    var res_version: int = parser_version.parse(FileAccess.get_file_as_string(self.directory().path_join("Font-Awesome-6.x/js-packages/@fortawesome/fontawesome-free/package.json")))
    if res_version != OK:
        push_warning("could not parse font awesome package.json: '%s'", [parser_version.get_error_message()])
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
        "Font-Awesome-6.x/js-packages/@fortawesome/fontawesome-free/package.json",
        "Font-Awesome-6.x/svgs/",
        "Font-Awesome-6.x/metadata/icons.json",
        "Font-Awesome-6.x/LICENSE.txt",
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
    downloader.await_request("https://raw.githubusercontent.com/FortAwesome/Font-Awesome/6.x/js-packages/%40fortawesome/fontawesome-free/package.json")
    if downloader.result != HTTPRequest.RESULT_SUCCESS:
        return

    var parser_version: JSON = JSON.new()
    var res_version: int = parser_version.parse(downloader.body.get_string_from_utf8())
    if res_version != OK:
        push_warning("could get latest font awesome version: '%s'", [parser_version.get_error_message()])
        return
    self.latest_version = parser_version.data["version"]

# OVERRIDE
func icon_directory() -> String:
    return self.directory().path_join("Font-Awesome-6.x/svgs/")
