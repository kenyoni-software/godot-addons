extends "res://addons/kenyoni/tolgee/internal/scripts/flow/flow.gd"

const Client := preload("res://addons/kenyoni/tolgee/internal/scripts/client.gd")

var _file_paths: Array[String] = []
var _done_paths: Array[String] = []

func _init(tolgee: Tolgee) -> void:
    super._init(tolgee)
    self.completed.connect(self._on_completed)

## OVERRIDE
func run() -> void:
    super.run()

    self._file_paths.clear()
    self._done_paths.clear()
    for tr_cfg: Dictionary in self._tolgee.files():
        self._file_paths.append(tr_cfg.get("output_path", ""))
    self._download_next()

func _download_next() -> void:
    if self._file_paths.size() == 0:
        self.completed.emit(OK)
        return
    var cur_file: String = self._file_paths[-1]
    var options: Client.ExportDataOptions = Client.ExportDataOptions.new()
    options.filter_namespace = [cur_file]
    options.message_format = Tolgee.placeholder_to_message_format(self._tolgee.placeholder())
    self._tolgee._client.export_data(self._tolgee.project_id(), "CSV", false, false, options, cur_file, self._on_download)

func _on_download(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, _body_json: Variant) -> void:
    if result != OK:
        var err_msg: String = str(result)
        push_error("[Tolgee] Failed to download translations: " + err_msg)
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to download translations.", EditorToaster.SEVERITY_ERROR, err_msg)
        self.completed.emit(FAILED)
        return
    if response_code != HTTPClient.RESPONSE_OK:
        var err_msg: String = "%s - %s" % [str(response_code), body.get_string_from_utf8()]
        push_error("[Tolgee] Failed to download translations: " + err_msg)
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to download translations.", EditorToaster.SEVERITY_ERROR, err_msg)
        self.completed.emit(FAILED)
        return

    self._done_paths.append(self._file_paths.pop_back())
    self._download_next()

func _on_completed(err: Error) -> void:
    if err == OK:
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Successfully downloaded translations.")
    elif self._done_paths.size() == 0:
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to download translations.", EditorToaster.SEVERITY_ERROR)
    else:
        var err_msg: String = ", ".join(self._done_paths)
        push_error("[Tolgee] Partially downloaded translations: " + err_msg)
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Partially downloaded translations.", EditorToaster.SEVERITY_WARNING, err_msg)
        EditorInterface.get_resource_filesystem().reimport_files(self._done_paths)
