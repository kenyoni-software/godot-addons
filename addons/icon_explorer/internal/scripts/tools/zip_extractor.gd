extends RefCounted
## Extracts a zip file to a directory.

signal completed()

var _zip_path: String
var _output_path: String
var _unpack_only: PackedStringArray

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

## The completed signal is called right before it returns.
func extract(zip_path: String, output_path: String, unpack_only: PackedStringArray = PackedStringArray()) -> Error:
    self._zip_path = zip_path
    self._output_path = output_path
    self._unpack_only = unpack_only
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
        if !self._is_in_filter(path):
            self._add_processed(1)
            continue
        # directories are already created
        if path.ends_with("/"):
            self._add_processed(1)
            continue
        var buffer: PackedByteArray = reader.read_file(path)
        var out_path: String = self._output_path.path_join(path)
        var file: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
        if file == null:
            reader.close()
            self._set_error(FileAccess.get_open_error(), "failed to open file " + out_path)
            self.completed.emit()
            return FileAccess.get_open_error()
        if !file.store_buffer(buffer):
            reader.close()
            self._set_error(file.get_error(), "failed to write file " + out_path)
            self.completed.emit()
            return file.get_error()
        file = null
        self._add_processed(1)
    reader.close()
    self._set_error(Error.OK, "")
    self.completed.emit()
    return Error.OK

func _add_processed(val: int) -> void:
    self._progress_guard.lock()
    self._processed += val
    self._progress_guard.unlock()

func _is_in_filter(path: String) -> bool:
    if self._unpack_only.size() == 0:
        return true
    for filter: String in self._unpack_only:
        if path.begins_with(filter):
            return true
    return false

func _create_directories(paths: PackedStringArray) -> Error:
    var created: Dictionary[String, Object] = {}
    for path: String in paths:
        var dir_path: String = path.get_base_dir()
        if self._is_in_filter(path) && !created.has(dir_path):
            var err: int = DirAccess.make_dir_recursive_absolute(self._output_path.path_join(dir_path))
            if err != Error.OK:
                return err as Error
            created[dir_path] = null
    return Error.OK

func _set_error(err: Error, msg: String) -> void:
    self._error_guard.lock()
    self._err = err
    self._err_msg = msg
    self._error_guard.unlock()
