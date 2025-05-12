extends "res://addons/kenyoni/tolgee/internal/scripts/flow/flow.gd"

const Client := preload("res://addons/kenyoni/tolgee/internal/scripts/client.gd")
const ZipExtractorThreaded := preload("res://addons/kenyoni/tolgee/internal/scripts/tools/zip_extractor_threaded.gd")

var _file_cfg: Array[Dictionary] = []
var _done_cfg: Array[Dictionary] = []
var _download_dir: DirAccess = null
var _extractor: ZipExtractorThreaded = null

func _init(tolgee: Tolgee) -> void:
    super._init(tolgee)
    self.completed.connect(self._on_completed)

## OVERRIDE
func run() -> void:
    super.run()

    self._file_cfg.clear()
    self._done_cfg.clear()
    self._download_dir = DirAccess.create_temp()
    if DirAccess.get_open_error() != OK:
        var err_msg: String = "Failed to create download directory: '%s' - %s" % [self._download_dir.get_path(), error_string(DirAccess.get_open_error())]
        push_error("[Tolgee] Failed to download translations: " + err_msg)
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to download translations.", EditorToaster.SEVERITY_ERROR, err_msg)
        self.completed.emit(FAILED)
        return
    for tr_cfg: Dictionary in self._tolgee.files():
        self._file_cfg.append(tr_cfg.duplicate())
    self._download_next()

func _download_next() -> void:
    if self._file_cfg.size() == 0:
        self.completed.emit(OK)
        return
    var cur_cfg: Dictionary = self._file_cfg[-1]
    var options: Client.ExportDataOptions = Client.ExportDataOptions.new()
    options.filter_namespace = [cur_cfg.get(Tolgee.FILES_KEY_NAMESPACE, "")]
    options.message_format = Tolgee.placeholder_to_message_format(cur_cfg.get(Tolgee.FILES_KEY_PLACEHOLDER, Tolgee.PLACEHOLDER_ICU))
    options.filter_state = ["UNTRANSLATED", "TRANSLATED", "REVIEWED"]
    var input_path: String = cur_cfg.get(Tolgee.FILES_KEY_INPUT_PATH, "")
    if input_path.get_extension() == "csv":
        options.file_structure_template = "translation.csv"
        self._tolgee._client.export_data(self._tolgee.project_id(), "CSV", false, false, options, input_path, self._on_csv_download)
    elif input_path.get_extension() == "pot":
        options.file_structure_template = "%s.{languageTag}.po" % [input_path.get_file().get_basename()]
        var output_path: String = self._download_dir.get_current_dir().path_join("translations.zip")
        self._tolgee._client.export_data(self._tolgee.project_id(), "PO", false, true, options, input_path, self._on_po_download)

func _on_csv_download(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, _body_json: Variant) -> void:
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

    self._done_cfg.append(self._file_cfg.pop_back())
    self._download_next()

func _on_po_download(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, _body_json: Variant) -> void:
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
    
    var tr_cfg: Dictionary = self._file_cfg[-1]
    var file_name_prefix: String = tr_cfg.get(Tolgee.FILES_KEY_INPUT_PATH, "").get_file().get_basename()
    var output_path: String = tr_cfg.get(Tolgee.FILES_KEY_OUTPUT_PATH, "")
    for file: String in DirAccess.get_files_at(tr_cfg.get(Tolgee.FILES_KEY_OUTPUT_PATH, "") as String):
        if file.get_extension() == "po" && file.begins_with(file_name_prefix):
            DirAccess.remove_absolute(output_path.path_join(file))

    self._download_dir.get_current_dir().path_join("translations.zip")
    self._extractor = ZipExtractorThreaded.new()
    self._extractor.thread_count = maxi(OS.get_processor_count() / 2, 1)
    self._extractor.completed.connect(self._on_extractor_completed)
    self._extractor.extract(
        self._download_dir.get_current_dir().path_join("translations.zip"),
        self._file_cfg[-1].get(Tolgee.FILES_KEY_INPUT_PATH, "").get_base_dir()
    )

func _on_extractor_completed(err: Error) -> void:
    if err != OK:
        var err_msg: String = "Failed to extract translations: %s - %s - %s" % [self._extractor.zip_path(), self._extractor.output_path(), self._extractor.error_message()]
        push_error("[Tolgee] Failed to download translations: " + err_msg)
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to download translations.", EditorToaster.SEVERITY_ERROR, err_msg)
        self.completed.emit(FAILED)
        return
    self._done_cfg.append(self._file_cfg.pop_back())
    self._download_next()

func _on_completed(err: Error) -> void:
    if err == OK:
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Successfully downloaded translations.")
    elif self._done_cfg.size() == 0:
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to download translations.", EditorToaster.SEVERITY_ERROR)
    else:
        var done_files: Array[String] = []
        for tr_cfg: Dictionary in self._done_cfg:
            done_files.append(tr_cfg.get(Tolgee.FILES_KEY_INPUT_PATH, ""))
        var err_msg: String = ", ".join(done_files)
        push_error("[Tolgee] Partially downloaded translations: " + err_msg)
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Partially downloaded translations.", EditorToaster.SEVERITY_WARNING, err_msg)
        EditorInterface.get_resource_filesystem().reimport_files(self._done_cfg)
