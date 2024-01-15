extends "res://addons/icon_explorer/internal/scripts/collection.gd"

const IconSimpleIcons := preload("res://addons/icon_explorer/internal/scripts/collections/icon_simple_icons.gd")
const ZipUnpacker := preload("res://addons/icon_explorer/internal/scripts/tools/zip_unpacker.gd")

const _DOWNLOAD_FILE: String = "https://github.com/simple-icons/simple-icons/archive/master.zip"
var _TITLE_TO_SLUG_REPLACEMENTS: Dictionary = {
    "+": "plus",
    ".": "dot",
    "&": "and",
    "đ": "d",
    "ħ": "h",
    "ı": "i",
    "ĸ": "k",
    "ŀ": "l",
    "ł": "l",
    "ß": "ss",
    "ŧ": "t",

    "ä": "a",
    "ã": "a",
    "á": "a",
    "é": "e",
    "è": "e",
    "ë": "e",
    "î": "i",
    "ö": "o",
    "ř": "r",
    "š": "s",
    "ü": "u",
    "ż": "z",
}

var _title_to_slug_range_rx: RegEx = RegEx.new()

func _init() -> void:
    self.name = "Simple Icons"
    self.version = ""
    self.author = ""
    self.license = "CC0 1.0 Universal / Others"
    self.web = "https://github.com/simple-icons/simple-icons"
    self.svg_size = 24.0

    self._title_to_slug_range_rx.compile("[^a-z0-9]")

# OVERRIDE
func convert_icon_colored(buffer: String, color: String) -> String:
    return '<svg fill="#' + color + '"' + buffer.substr(4)

func _title_to_slug(title: String) -> String:
    title = title.to_lower()
    for src: String in _TITLE_TO_SLUG_REPLACEMENTS.keys():
        title = title.replace(src, _TITLE_TO_SLUG_REPLACEMENTS[src])
    title = self._title_to_slug_range_rx.sub(title, '', true)
    return title

# OVERRIDE
func load() -> Array:
    var parser_version: JSON = JSON.new()
    var res_version: int = parser_version.parse(FileAccess.get_file_as_string(self.directory().path_join("simple-icons-master/package.json")))
    if res_version != OK:
        push_warning("could not parse simple icons package.json: '%s'", [parser_version.get_error_message()])
        return [[], PackedStringArray()]
    self.version = parser_version.data["version"]

    var parser: JSON = JSON.new()
    var res: int = parser.parse(FileAccess.get_file_as_string(self.directory().path_join("simple-icons-master/_data/simple-icons.json")))
    if res != OK:
        push_warning("could not parse simple icons simple-icons.json: '%s'", [parser.get_error_message()])
        return [[], PackedStringArray()]

    var icons: Array[Icon] = []
    var buffers: PackedStringArray = PackedStringArray()
    for item: Dictionary in parser.data.get("icons", []):
        var arr_res: Array = self._load_item(item)
        if arr_res.size() == 0:
            continue
        icons.append(arr_res[0])
        buffers.append(arr_res[1])
        for dup: Dictionary in item.get("aliases", {}).get("dup", []):
            var dup_item: Dictionary = item.duplicate(true)
            dup_item.merge(dup, true)
            arr_res = self._load_item(item)
            if arr_res.size() == 2:
                icons.append(arr_res[0])
                buffers.append(arr_res[1])

    return [icons, buffers]

func _load_item(item: Dictionary) -> Array:
    var icon: IconSimpleIcons = IconSimpleIcons.new()
    icon.collection = self
    icon.name = item["title"]
    
    if item.has("slug"):
        icon.icon_path = self.icon_directory().path_join(item["slug"] + ".svg")
    else:
        icon.icon_path = self.icon_directory().path_join(self._title_to_slug(icon.name) + ".svg")

    var hex: String = item.get("hex", "")
    if hex != "":
        icon.hex = Color.from_string(hex, Color())
    icon.source = item.get("source", "")
    var aliases: Dictionary = item.get("aliases", {})
    icon.aliases = aliases.get("aka", PackedStringArray())
    icon.aliases.append_array(aliases.get("loc", {}).values())
    icon.aliases.append_array(aliases.get("old", PackedStringArray()))
    icon.license = item.get("license", {}).get("type", "")
    icon.license_link = item.get("license", {}).get("url", "")
    icon.guidelines = item.get("guidelines", "")

    var buffer: String = FileAccess.get_file_as_string(icon.icon_path)
    if buffer == "":
        push_warning("could not load '" + icon.icon_path + "'")
        return []

    return [icon, self.convert_icon_colored(buffer, "FFFFFF")]

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
        "simple-icons-master/package.json",
        "simple-icons-master/icons/",
        "simple-icons-master/_data/simple-icons.json",
        "simple-icons-master/LICENSE.md",
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
    return self.directory().path_join("simple-icons-master/icons/")
