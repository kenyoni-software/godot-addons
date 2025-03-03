extends "res://addons/icon_explorer/internal/scripts/collection.gd"

const IconBootstrap := preload("res://addons/icon_explorer/internal/ext/bootstrap/icon.gd")
const ZipExtractorThreaded := preload("res://addons/icon_explorer/internal/scripts/tools/zip_extractor_threaded.gd")

const _DOWNLOAD_FILE: String = "https://github.com/twbs/icons/archive/main.zip"

func _init() -> void:
    self.name = "Bootstrap Icons"
    self.version = ""
    self.author = "The Bootstrap Authors"
    self.license = "MIT"
    self.web = "https://github.com/twbs/icons"

# OVERRIDE
func color_icon(buffer: String, color: String) -> String:
    return buffer.replace("currentColor", "#" + color)

# OVERRIDE
func load() -> Array:
    var dir: DirAccess = DirAccess.open(self._meta_directory())
    if !dir:
        return [[], PackedStringArray()]
    
    var icons: Array[Icon] = []
    var buffers: PackedStringArray = PackedStringArray()
    dir.list_dir_begin()
    var file_name: String = dir.get_next()
    while file_name != "":
        if dir.current_is_dir():
            file_name = dir.get_next()
            continue
        var res: Array = self._load_item(file_name)
        if res.size() == 2:
            icons.append(res[0])
            buffers.append(res[1])
        file_name = dir.get_next()
    dir.list_dir_end()
    dir = null

    var parser_version: JSON = JSON.new()
    var res_version: int = parser_version.parse(FileAccess.get_file_as_string(self.directory().path_join("icons-main/package.json")))
    if res_version != OK:
        push_warning("could not parse bootstrap package.json: '%s'", [parser_version.get_error_message()])
        return [[], PackedStringArray()]
    self.version = parser_version.data["version"]

    return [icons, buffers]

func _load_item(file_name: String) -> Array:
    var icon: IconBootstrap = IconBootstrap.new()
    icon.collection = self
    icon.svg_size = Vector2i(16, 16)
    icon.colorable = true

    var meta: String = FileAccess.get_file_as_string(self._meta_directory().path_join(file_name))
    if meta == "":
        push_warning("could not read bootstrap meta file '", file_name, "'")
        return []
    
    var cur_token: int = 0
    for line: String in meta.split("\n"):
        if line.begins_with("title: "):
            icon.name = line.lstrip("title: ")
            cur_token = 0
            continue
        if line == "categories:":
            cur_token = 1
            continue
        if line == "tags:":
            cur_token = 2
            continue
        if line.begins_with("  - "):
            match cur_token:
                1:
                    icon.categories.append(line.lstrip("  - "))
                2:
                    icon.tags.append(line.lstrip("  - "))
            continue
        if line.begins_with("added:"):
            icon.version_added = line.lstrip("added: ")

    if icon.name == "":
        push_warning("bootstrap '", file_name, "' has no name")
        return []

    icon.icon_path = self.icon_directory().path_join(file_name.get_basename() + ".svg")
    var buffer: String = FileAccess.get_file_as_string(icon.icon_path)
    if buffer == "":
        push_warning("could not load '" + icon.icon_path + "'")
        return []
   
    return [icon, self.color_icon(buffer, "FFFFFF")]

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
        "icons-main/package.json",
        "icons-main/icons/",
        "icons-main/docs/content/icons/",
        "icons-main/LICENSE",
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
    downloader.await_request("https://raw.githubusercontent.com/twbs/icons/main/package.json")
    if downloader.result != HTTPRequest.RESULT_SUCCESS:
        return

    var parser_version: JSON = JSON.new()
    var res_version: int = parser_version.parse(downloader.body.get_string_from_utf8())
    if res_version != OK:
        push_warning("could get latest bootstrap version: '%s'", [parser_version.get_error_message()])
        return
    self.latest_version = parser_version.data["version"]

# OVERRIDE
func icon_directory() -> String:
    return self.directory().path_join("icons-main/icons/")

func _meta_directory() -> String:
    return self.directory().path_join("icons-main/docs/content/icons/")
