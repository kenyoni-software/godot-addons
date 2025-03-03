extends "res://addons/icon_explorer/internal/scripts/tools/zip_extractor.gd"
## Extracts a zip file to a directory.
## The threaded version might not be faster than the non-threaded version, if there are lot of directories.
## The directories are created in a single thread.

var thread_count: int = 1

var _main_thread: Thread
var _running_guard: Mutex = Mutex.new()

var _cancel_sem: Semaphore = Semaphore.new()

## Returns
## - ERR_CANT_CREATE if failed to create
## - ERR_BUSY if already processing an extraction
## - Error.OK if successful created
## The completed signal is called deferred. And is only called if extract returns Error.OK and the process was started.
func extract(zip_path: String, output_path: String, unpack_only: PackedStringArray = PackedStringArray()) -> Error:
    if !self._running_guard.try_lock():
        return ERR_BUSY
    if self._main_thread != null && self._main_thread.is_alive():
        self._running_guard.unlock()
        return ERR_BUSY

    self._zip_path = zip_path
    if !output_path.is_absolute_path():
        output_path = OS.get_executable_path().get_base_dir().path_join(output_path)
    self._output_path = output_path
    self._unpack_only = unpack_only
    self._set_error(Error.OK, "")

    self._main_thread = Thread.new()
    var err: Error = self._main_thread.start(self._extract_main)
    if err != Error.OK:
        self._set_error(err, "failed to start main thread")
    return err

## Alias for wait
func close() -> void:
    self.wait()

func wait() -> void:
    if self._main_thread != null && self._main_thread.is_started():
        self._main_thread.wait_to_finish()

func _extract_main() -> void:
    var reader: ZIPReader = ZIPReader.new()
    var err: Error = reader.open(self._zip_path)
    if err != Error.OK:
        self._set_error(err, "failed to open zip file")
        self.completed.emit.call_deferred()
        return

    var files: PackedStringArray = reader.get_files()
    err = reader.close()
    if err != Error.OK:
        self._set_error(err, "failed to close zip file")
        self.completed.emit.call_deferred()
    self._progress_guard.lock()
    self._processed = 0
    self._total = files.size()
    self._progress_guard.unlock()

    err = self._create_directories(files)
    if err != Error.OK:
        self._set_error(err, "failed to create directories")
        self.completed.emit.call_deferred()
        return

    var threads: Array[Thread] = []
    threads.resize(self.thread_count)

    self._cancel_sem.post(threads.size())
    var batch_size: int = maxi(files.size() / threads.size(), 1)
    for thread_idx: int in range(threads.size()):
        var start_idx: int = thread_idx * batch_size
        var end_idx: int = start_idx + batch_size
        # last thread takes the rest
        if thread_idx == threads.size() - 1:
            end_idx = files.size()
        # do not create threads if not more files are left
        if start_idx >= files.size():
            break

        threads[thread_idx] = Thread.new()
        err = threads[thread_idx].start(self._extract_files.bind(files.slice(start_idx, end_idx)))
        if err != Error.OK:
            self._cancel()
            self._set_error(err, "failed to start worker thread")
            self.completed.emit.call_deferred()
            break

    for thread: Thread in threads:
        if thread != null && thread.is_started():
            thread.wait_to_finish()
    self._cancel()
    self.completed.emit.call_deferred()

func _extract_files(files: PackedStringArray) -> void:
    var reader: ZIPReader = ZIPReader.new()
    var err: Error = reader.open(self._zip_path)
    if err != Error.OK:
        self._cancel()
        self._set_error(err, "failed to open zip file")
        self.completed.emit.call_deferred()
        return

    for path: String in files:
        if !self._cancel_sem.try_wait():
            return
        # add itself again
        self._cancel_sem.post()
        if !self._is_in_filter(path):
            self._add_processed(1)
            continue
        if path.ends_with("/"):
            self._add_processed(1)
            continue
        var file: FileAccess = FileAccess.open(self._output_path.path_join(path), FileAccess.WRITE)
        if file == null:
            self._cancel()
            self._set_error(FileAccess.get_open_error(), "failed to open file " + self._output_path.path_join(path))
            self.completed.emit.call_deferred()
            return
        if !file.store_buffer(reader.read_file(path)):
            self._cancel()
            self._set_error(file.get_error(), "failed to write file " + self._output_path.path_join(path))
            self.completed.emit.call_deferred()
            return
        self._add_processed(1)
    err = reader.close()
    if err != Error.OK:
        self._cancel()
        self._set_error(err, "failed to close zip file")
        self.completed.emit.call_deferred()

func _cancel() -> void:
    while self._cancel_sem.try_wait():
        pass
