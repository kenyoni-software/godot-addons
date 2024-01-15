extends RefCounted

const Io := preload("res://addons/icon_explorer/internal/scripts/tools/io.gd")
const Icon := preload("res://addons/icon_explorer/internal/scripts/icon.gd")

# target svg texture size
const TEXTURE_SIZE: float = 128.0

var name: String
var version: String
var author: String
var license: String
var license_text: String
var web: String

## base size of svg
var svg_size: float

# is set on registering it at the IconDatabase
var _id: int = -1

func id() -> int:
    return self._id

func is_installed() -> bool:
    return DirAccess.dir_exists_absolute(self.icon_directory())

# VIRTUAL
func convert_icon_colored(buffer: String, color: String) -> String:
    return ""

# VIRTUAL
# called in a thread
func load() -> Array[Icon]:
    assert(false, "virtual function")
    return []

# VIRTUAL
# called in a thread
func install(http: HTTPRequest, version: String) -> Error:
    assert(false, "virtual function")
    return Error.FAILED

# VIRTUAL
# called in a thread
func remove() -> Error:
    if Io.rrm_dir(self.directory()):
        return Error.OK
    return Error.FAILED

# VIRTUAL
func icon_directory() -> String:
    assert(false, "virtual function")
    return ""

func directory() -> String:
    if Engine.is_editor_hint():
        if ProjectSettings.get_setting("application/config/use_hidden_project_data_directory", true):
            return "res://.godot/cache/icon_explorer".path_join(self.directory_name())
        else:
            return "res://godot/cache/icon_explorer".path_join(self.directory_name())
    assert(false, "TODO")
    return ""

func directory_name() -> String:
    return self.name.to_snake_case()
