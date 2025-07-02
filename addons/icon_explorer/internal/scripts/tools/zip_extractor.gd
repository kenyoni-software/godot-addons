extends RefCounted
## Extracts a zip file to a directory.

signal completed()

var _zip_path: String
var _output_path: String
## Callable[[String], String]
## The extract hook can return a relative path to the output path or an absolute path. Returning an empty string will skip the file.
var _extract_hook: Variant = null

var _processed: int = 0:
    get = processed_files
var _total: int = 0:
    get = total_files
var _progress_guard: Mutex = Mutex.new()

var _err: Error:
    get = error
var _err_msg: String:
    get = error_message
var _error_guard: Mutex = Mutex.new()

func zip_path() -> String:
    return self._zip_path

func output_path() -> String:
    return self._output_path

func processed_files() -> int:
    self._progress_guard.lock()
    var value: int = _processed
    self._progress_guard.unlock()
    return value

func total_files() -> int:
    self._progress_guard.lock()
    var value: int = _total
    self._progress_guard.unlock()
    return value

func error() -> Error:
    self._error_guard.lock()
    var value: Error = _err
    self._error_guard.unlock()
    return value

func error_message() -> String:
    self._error_guard.lock()
    var value: String = _err_msg
    self._error_guard.unlock()
    return value

func _init(extract_hook: Variant = null) -> void:
    self._extract_hook = extract_hook

## The completed signal is called right before it returns.
func extract(zip_path: String, output_path: String) -> Error:
    self._zip_path = zip_path
    self._output_path = output_path
    self._set_error(Error.OK, "")

    var reader: ZIPReader = ZIPReader.new()
    var err: Error = reader.open(self._zip_path)
    if err != Error.OK:
        self._set_error(err, "failed to open zip file")
        self.completed.emit()
        return err

    var files: PackedStringArray = reader.get_files()
    self._progress_guard.lock()
    self._processed = 0
    self._total = files.size()
    self._progress_guard.unlock()

    err = self._create_directories(files)
    if err != Error.OK:
        self._set_error(err, "failed to create directories")
        self.completed.emit()
        return err
    for path: String in files:
        # directories are already created
        if path.ends_with("/"):
            self._add_processed(1)
            continue
        var file_out_path: String = self._get_output_path(path)
        if file_out_path == "":
            self._add_processed(1)
            continue
        var buffer: PackedByteArray = reader.read_file(path)
        var file: FileAccess = FileAccess.open(file_out_path, FileAccess.WRITE)
        if file == null:
            reader.close()
            self._set_error(FileAccess.get_open_error(), "failed to open file " + file_out_path)
            self.completed.emit()
            return FileAccess.get_open_error()
        if !file.store_buffer(buffer):
            reader.close()
            self._set_error(file.get_error(), "failed to write file " + file_out_path)
            self.completed.emit()
            return file.get_error()
        file = null
        self._add_processed(1)
    err = reader.close()
    if err != Error.OK:
        self._set_error(err, "failed to close zip file")
        self.completed.emit()
    self._set_error(Error.OK, "")
    self.completed.emit()
    return Error.OK

func _add_processed(val: int) -> void:
    self._progress_guard.lock()
    self._processed += val
    self._progress_guard.unlock()

func _get_output_path(path: String) -> String:
    if self._extract_hook == null:
        return self._output_path.path_join(path)
    var file_out_path: String = (self._extract_hook as Callable).call(path)
    if file_out_path == "":
        return ""
    if file_out_path.is_absolute_path():
        return file_out_path
    return self._output_path.path_join(file_out_path)

func _create_directories(paths: PackedStringArray) -> Error:
    var created: Dictionary[String, Object] = {}
    for path: String in paths:
        var file_out_path: String = self._get_output_path(path)
        if file_out_path == "":
            continue
        var output_dir: String = file_out_path.get_base_dir()
        if !created.has(output_dir):
            var err: int = DirAccess.make_dir_recursive_absolute(output_dir)
            if err != Error.OK:
                return err as Error
            created[output_dir] = null
    return Error.OK

func _set_error(err: Error, msg: String) -> void:
    self._error_guard.lock()
    self._err = err
    self._err_msg = msg
    self._error_guard.unlock()
