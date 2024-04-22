extends "res://addons/icon_explorer/internal/scripts/collection.gd"

const IconCountryFlags := preload("res://addons/icon_explorer/internal/ext/country_flag_icons/icon.gd")
const ZipUnpacker := preload("res://addons/icon_explorer/internal/scripts/tools/zip_unpacker.gd")

const _DOWNLOAD_FILE: String = "https://gitlab.com/catamphetamine/country-flag-icons/-/archive/master/country-flag-icons-master.zip"

func _init() -> void:
    self.name = "Country Flag Icons"
    self.version = ""
    self.author = "Nikolay Kuchumov"
    self.license = "Public Domain"
    self.web = "https://gitlab.com/catamphetamine/country-flag-icons"

# OVERRIDE
func load() -> Array:
    var dir: DirAccess = DirAccess.open(self.icon_directory())
    if !dir:
        return [[], PackedStringArray()]

    var flag_names: JSON = JSON.new()
    var res_flag_names: int = flag_names.parse(FileAccess.get_file_as_string(self.directory().path_join("country-flag-icons-master/runnable/countryNames.json")))
    if res_flag_names != OK:
        push_warning("could not parse country flag icons countryNames.json: '%s'", [flag_names.get_error_message()])
        return [[], PackedStringArray()]
    
    var icons: Array[Icon] = []
    var buffers: PackedStringArray = PackedStringArray()
    dir.list_dir_begin()
    var file_name: String = dir.get_next()
    while file_name != "":
        if dir.current_is_dir():
            file_name = dir.get_next()
            continue

        var icon: IconCountryFlags = IconCountryFlags.new()
        icon.collection = self
        icon.colorable = false
        icon.country_code = file_name.get_basename().to_upper()
        icon.icon_path = self.icon_directory().path_join(file_name)
        icon.name = flag_names.data[icon.country_code.split("-")[-1]]
        if icon.name == "":
            push_warning("country flag icons '", file_name, "' has no name")
            file_name = dir.get_next()
            continue

        icons.append(icon)

        var buffer: String = FileAccess.get_file_as_string(icon.icon_path)
        icon.svg_size = Icon.get_svg_size(buffer)
        buffers.push_back(buffer)
        file_name = dir.get_next()
    dir.list_dir_end()
    dir = null

    var parser_version: JSON = JSON.new()
    var res_version: int = parser_version.parse(FileAccess.get_file_as_string(self.directory().path_join("country-flag-icons-master/package.json")))
    if res_version != OK:
        push_warning("could not parse country flag icons package.json: '%s'", [parser_version.get_error_message()])
        return [[], PackedStringArray()]
    self.version = parser_version.data["version"]

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
        "country-flag-icons-master/3x2/",
        "country-flag-icons-master/package.json",
        "country-flag-icons-master/runnable/countryNames.json",
        "country-flag-icons-master/LICENSE",
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
    return self.directory().path_join("country-flag-icons-master/3x2/")
