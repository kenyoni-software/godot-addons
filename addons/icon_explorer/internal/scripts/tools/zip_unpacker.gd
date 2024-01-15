extends RefCounted

var _zip_path: String
var _output_path: String
var _unpack_only: PackedStringArray

## Filter is compared with begins_with
func _init(zip_path: String, output_path: String, unpack_only: PackedStringArray = PackedStringArray()) -> void:
    self._zip_path = zip_path
    self._output_path = output_path
    self._unpack_only = unpack_only

func _has_filter() -> bool:
    return self._unpack_only.size() != 0

func _is_in_filter(path: String) -> bool:
    if !self._has_filter():
        return true
    for filter: String in self._unpack_only:
        if path.begins_with(filter):
            return true
    return false

func unpack() -> bool:
    var reader := ZIPReader.new()
    var err: Error = reader.open(self._zip_path)
    if err != Error.OK:
        return false

    if !self._create_directories(reader.get_files()):
        return Error.FAILED
    var files: PackedStringArray = reader.get_files()
    for idx: int in range(files.size()):
        var path: String = files[idx]
        if !self._is_in_filter(path):
            continue
        var buffer: PackedByteArray = reader.read_file(path)
        var file: FileAccess = FileAccess.open(self._output_path.path_join(path), FileAccess.WRITE)
        if file == null:
            reader.close()
            return false
        file.store_buffer(buffer)
        file = null
    reader.close()
    return true

# Unpack with multiple threads. Is a blocking call nontheless.
func unpack_mt(thread_count: int) -> bool:
    var threads: Array[Thread] = []
    for idx: int in range(thread_count):
        threads.append(Thread.new())

    var reader := ZIPReader.new()
    var err: Error = reader.open(self._zip_path)
    if err != Error.OK:
        return false

    if !self._create_directories(reader.get_files()):
        return Error.FAILED
    var file_count: int = reader.get_files().size()
    reader.close()

    var steps: int = file_count / threads.size()
    for thread_idx: int in range(threads.size()):
        var start_idx: int = thread_idx * steps
        var end_idx: int = start_idx + steps
        if thread_idx == threads.size() - 1:
            end_idx = file_count
        threads[thread_idx].start(self._unpack_fn.bind(start_idx, end_idx))
    for thread: Thread in threads:
        thread.wait_to_finish()
    return true

func _create_directories(paths: PackedStringArray) -> bool:
    var created: Dictionary = {}
    for path: String in paths:
        var dir_path: String = path.get_base_dir()
        if (!self._has_filter() || self._is_in_filter(path)) && !(dir_path in created):
            if DirAccess.make_dir_recursive_absolute(self._output_path.path_join(path.get_base_dir())) != Error.OK:
                return false
            created[dir_path] = null
    return true

func _unpack_fn(from: int, to: int) -> void:
    var reader := ZIPReader.new()
    var err: Error = reader.open(self._zip_path)
    if err != Error.OK:
        return

    var files: PackedStringArray = reader.get_files()
    for idx: int in range(from, to):
        var path: String = files[idx]
        if !self._is_in_filter(path):
            continue
        if path.ends_with("/"):
            continue
        var file: FileAccess = FileAccess.open(self._output_path.path_join(path), FileAccess.WRITE)
        if file == null:
            continue
        file.store_buffer(reader.read_file(path))
        file = null
