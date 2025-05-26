extends "res://addons/kenyoni/tolgee/internal/scripts/flow/flow.gd"

const Client := preload("res://addons/kenyoni/tolgee/internal/scripts/client.gd")
const ZipExtractorThreaded := preload("res://addons/kenyoni/tolgee/internal/scripts/tools/zip_extractor_threaded.gd")

var _file_cfg: Array[Dictionary] = []
var _done_cfg: Array[Dictionary] = []
var _download_dir: DirAccess = null
var _extractor: ZipExtractorThreaded = null

## languages from last PO file download as BCP 47
var _languages: Array[String] = []

func _init(tolgee: Tolgee) -> void:
    super._init(tolgee)

## OVERRIDE
func run() -> void:
    super.run()

    self._file_cfg.clear()
    self._done_cfg.clear()
    self._download_dir = DirAccess.create_temp("-")
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
        self._tolgee._client.export_data(self._tolgee.project_id(), "CSV", false, false, options, input_path, self._on_csv_download)
    elif input_path.get_extension() == "pot":
        options.file_structure_template = "%s.{languageTag}.{extension}" % [input_path.get_file().get_basename()]
        var output_path: String = self._download_dir.get_current_dir().path_join("translations.zip")
        self._tolgee._client.export_data(self._tolgee.project_id(), "PO", false, true, options, output_path, self._on_po_download)

## required until Tolgee provides a language mapping on export
## https://github.com/tolgee/tolgee-platform/issues/3025
func _csv_post_download(input_path: String) -> Error:
    var file: FileAccess = FileAccess.open(input_path, FileAccess.READ)
    var content: Array[PackedStringArray] = []

    if file == null:
        var err_msg: String = "Failed to open file: '%s' - %s" % [input_path, error_string(FileAccess.get_open_error())]
        push_error("[Tolgee] Failed to ^convert locale: " + err_msg)
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to convert locale.", EditorToaster.SEVERITY_ERROR, err_msg)
        self.completed.emit(FAILED)
        return FAILED
    while file.get_position() < file.get_length():
        content.append(file.get_csv_line())
    file.close()
    for idx in range(content[0].size()):
        content[0][idx] = Tolgee.bcp47_to_locale(content[0][idx])
    file = FileAccess.open(input_path, FileAccess.WRITE)
    if file == null:
        var err_msg: String = "Failed to open file: '%s' - %s" % [input_path, error_string(FileAccess.get_open_error())]
        push_error("[Tolgee] Failed to save converted locale: " + err_msg)
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to save converted locale.", EditorToaster.SEVERITY_ERROR, err_msg)
        self.completed.emit(FAILED)
        return FAILED
    for line in content:
        file.store_csv_line(line)
    file.close()
    EditorInterface.get_resource_filesystem().reimport_files([input_path])
    return OK

## required until Tolgee provides a language mapping on export
## https://github.com/tolgee/tolgee-platform/issues/3025
func _pot_post_download(input_path: String) -> Error:
    var file: FileAccess = FileAccess.open(input_path, FileAccess.READ)
    var content: Array[PackedStringArray] = []

    if file == null:
        var err_msg: String = "Failed to open file: '%s' - %s" % [input_path, error_string(FileAccess.get_open_error())]
        push_error("[Tolgee] Failed to ^convert locale: " + err_msg)
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to convert locale.", EditorToaster.SEVERITY_ERROR, err_msg)
        self.completed.emit(FAILED)
        return FAILED
    while file.get_position() < file.get_length():
        content.append(file.get_csv_line())
    file.close()
    for idx in range(content[0].size()):
        content[0][idx] = Tolgee.bcp47_to_locale(content[0][idx])
    file = FileAccess.open(input_path, FileAccess.WRITE)
    if file == null:
        var err_msg: String = "Failed to open file: '%s' - %s" % [input_path, error_string(FileAccess.get_open_error())]
        push_error("[Tolgee] Failed to save converted locale: " + err_msg)
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to save converted locale.", EditorToaster.SEVERITY_ERROR, err_msg)
        self.completed.emit(FAILED)
        return FAILED
    for line in content:
        file.store_csv_line(line)
    file.close()
    EditorInterface.get_resource_filesystem().reimport_files([input_path])
    return OK

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

    self._csv_post_download(self._file_cfg[-1].get(Tolgee.FILES_KEY_INPUT_PATH, ""))
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

    self._extractor = ZipExtractorThreaded.new(self._collect_pot_languages)
    self._extractor.thread_count = maxi(OS.get_processor_count() / 2, 1)
    self._extractor.completed.connect(self._on_extractor_completed, CONNECT_ONE_SHOT)
    self._extractor.extract(
        self._download_dir.get_current_dir().path_join("translations.zip"),
        self._file_cfg[-1].get(Tolgee.FILES_KEY_INPUT_PATH, "").get_base_dir()
    )

func _collect_pot_languages(path: String) -> String:
    if path.get_extension() == "po":
        var lang: String = path.get_file().get_basename().get_extension()
        if !self._languages.has(lang):
            self._languages.append(lang)
    return path.get_file()

func _on_extractor_completed() -> void:
    var err: Error = self._extractor.error()
    if err != OK:
        var err_msg: String = "Failed to extract translations: %s - %s - %s" % [self._extractor.zip_path(), self._extractor.output_path(), self._extractor.error_message()]
        push_error("[Tolgee] Failed to download translations: " + err_msg)
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to download translations.", EditorToaster.SEVERITY_ERROR, err_msg)
        self.completed.emit(FAILED)
        return
    
    var tr_cfg: Dictionary = self._file_cfg[-1]
    var file_name_prefix: String = tr_cfg.get(Tolgee.FILES_KEY_INPUT_PATH, "").get_file().get_basename()
    var output_dir: String = tr_cfg.get(Tolgee.FILES_KEY_OUTPUT_PATH, "")

    var rx_lang: RegEx = RegEx.new()
    rx_lang.compile("msgid \"\"\n((?:.|\n)*)\"Language: (.+)\\n")
    ## name files with Godot locale instead of BCP47
    for lang: String in self._languages:
        var locale: String = Tolgee.bcp47_to_locale(lang)
        if lang == locale.to_lower():
            print("skip", lang)
            continue

        # replace language in po file
        var origin: String = output_dir.path_join(file_name_prefix + "." + lang + ".po")
        var text: String = FileAccess.get_file_as_string(origin)
        if text == "" && FileAccess.get_open_error() != OK:
            var err_msg: String = "Failed to change Godot locale of file (open): '%s' - %s" % [origin, error_string(FileAccess.get_open_error())]
            push_error("[Tolgee] Failed to download translations: " + err_msg)
            EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to download translations.", EditorToaster.SEVERITY_ERROR, err_msg)
            self.completed.emit(FAILED)
            return
        var file: FileAccess = FileAccess.open(origin, FileAccess.WRITE)
        if file == null:
            var err_msg: String = "Failed to change Godot locale of file (write): '%s' - %s" % [origin, error_string(FileAccess.get_open_error())]
            push_error("[Tolgee] Failed to download translations: " + err_msg)
            EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to download translations.", EditorToaster.SEVERITY_ERROR, err_msg)
            self.completed.emit(FAILED)
            return
        if !file.store_string(rx_lang.sub(text, "msgid \"\"\n$1\"Language: REPL\\n\"\n")):
            var err_msg: String = "Failed to change Godot locale of file (store): '%s' - %s" % [origin, error_string(FileAccess.get_open_error())]
            push_error("[Tolgee] Failed to download translations: " + err_msg)
            EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to download translations.", EditorToaster.SEVERITY_ERROR, err_msg)
            self.completed.emit(FAILED)
            return
        file.close()

        var dest: String = output_dir.path_join(file_name_prefix + "." + locale.to_lower() + ".po")
        err = DirAccess.rename_absolute(origin, dest)
        if err != OK:
            var err_msg: String = "Failed to rename file: '%s' -> %s : %s" % [origin, dest, error_string(err)]
            push_error("[Tolgee] Failed to download translations: " + err_msg)
            EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to download translations.", EditorToaster.SEVERITY_ERROR, err_msg)
            self.completed.emit(FAILED)
            return

    ## remove all other languages
    for file: String in DirAccess.get_files_at(output_dir):
        if file.get_extension() != "po" || !file.begins_with(file_name_prefix):
            continue
        var file_lang: String = file.get_file().get_basename().get_extension()
        for lang: String in self._languages:
            if Tolgee.bcp47_to_locale(lang).to_lower() == file_lang:
                continue
        err = DirAccess.remove_absolute(output_dir.path_join(file))
        if err != OK:
            var err_msg: String = "Failed to delete file: '%s' - %s" % [output_dir.path_join(file), error_string(err)]
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
