## recursive remove directory
static func rrm_dir(dir_path: String) -> bool:
    var dir: DirAccess = DirAccess.open(dir_path)
    if !dir:
        return false
    
    dir.list_dir_begin()
    var file_name: String = dir.get_next()
    while file_name != "":
        if dir.current_is_dir():
            if !rrm_dir(dir_path.path_join(file_name)):
                return false
        else:
            if dir.remove(file_name) != Error.OK:
                return false
        file_name = dir.get_next()
    DirAccess.remove_absolute(dir_path)
    return true

class FileDownloader:
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
        self._http.request(uri)
        var res: Array = await self._http.request_completed
        self.from_array(res)
        self._sema.post()

    func wait() -> void:
        self._sema.wait()
