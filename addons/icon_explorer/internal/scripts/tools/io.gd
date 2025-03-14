## recursive remove directory
static func rrm_dir(dir_path: String) -> Error:
    var dir: DirAccess = DirAccess.open(dir_path)
    if !dir:
        return DirAccess.get_open_error()
    
    var err: Error = dir.list_dir_begin()
    if err != Error.OK:
        return err
    var file_name: String = dir.get_next()
    while file_name != "":
        err = Error.OK
        if dir.current_is_dir():
            err = rrm_dir(dir_path.path_join(file_name))
        else:
            err = dir.remove(file_name)
        if err != Error.OK:
            dir.list_dir_end()
            return err
        file_name = dir.get_next()
    dir.list_dir_end()
    dir = null
    err = DirAccess.remove_absolute(dir_path)
    if err != Error.OK:
        return err
    return Error.OK


class Downloader:
    extends RefCounted

    var result: int
    var response_code: int
    var headers: PackedStringArray
    var body: PackedByteArray

    var _http: HTTPRequest
    var _sema: Semaphore

    func _init(http: HTTPRequest) -> void:
        self._http = http
        self._sema = Semaphore.new()

    func from_array(res_arr: Array):
        self.result = res_arr[0]
        self.response_code = res_arr[1]
        self.headers = res_arr[2]
        self.body = res_arr[3]
        return self

    # call on main thread
    func request(uri: String) -> void:
        var err: Error = self._http.request(uri)
        if err != Error.OK:
            self.from_array([err, 0, [], []])
            self._sema.post()
            return
        var res: Array = await self._http.request_completed
        self.from_array(res)
        self._sema.post()
    
    func await_request(uri: String) -> void:
        self.request.bind(uri).call_deferred()
        self.wait()

    func wait() -> void:
        self._sema.wait()
