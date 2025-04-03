extends "res://addons/kenyoni/tolgee/internal/scripts/flow/flow.gd"

const Client := preload("res://addons/kenyoni/tolgee/internal/scripts/client.gd")
const UpdateLanguagesFlow := preload("res://addons/kenyoni/tolgee/internal/scripts/flow/update_languages.gd")

func _init(tolgee: Tolgee) -> void:
    super._init(tolgee)

var _params: Client.PostSingleStepImportParams = null

## OVERRIDE
func run() -> void:
    super.run()

    var languages: Array[String] = []
    self._params = Client.PostSingleStepImportParams.new()
    self._params.convert_placeholders_to_icu = true
    self._params.create_new_keys = true
    self._params.remove_other_keys = true
    self._params.force_mode = "KEEP"

    for file_path: String in ProjectSettings.get_setting(Tolgee.CFG_KEY_CSV_FILES, []):
        file_path = Tolgee.uid_to_path(file_path)
        var file_data: PackedByteArray = FileAccess.get_file_as_bytes(file_path)
        if file_data.size() == 0 && FileAccess.get_open_error() != OK:
            var err_msg: String = "Failed to open file: '%s' - %s" % [file_path, error_string(FileAccess.get_open_error())]
            push_error("[Tolgee] Failed to upload translations: " + err_msg)
            EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to upload translations.", EditorToaster.SEVERITY_ERROR, err_msg)
            self.completed.emit(FAILED)
            return
        
        self._params.files.append(Client.PostSingleStepImportFile.new(file_path.get_file(), file_data))
        var file_mapping: Client.PostSingleStepImportFileMapping = Client.PostSingleStepImportFileMapping.new(file_path.get_file())
        file_mapping.format = "CSV_" + self._tolgee.placeholder().to_upper()
        file_mapping.namespace_str = file_path
        self._params.file_mappings.append(file_mapping)

        # collect languages
        var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
        if file == null:
            var err_msg: String = "Failed to open file: '%s' - %s" % [file_path, error_string(FileAccess.get_open_error())]
            push_error("[Tolgee] Failed to upload translations: " + err_msg)
            EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to upload translations.", EditorToaster.SEVERITY_ERROR, err_msg)
            self.completed.emit(FAILED)
            return
        var cur_languages: PackedStringArray = file.get_csv_line()
        file.close()
        cur_languages.remove_at(0)
        for cur_lang: String in cur_languages:
            if !languages.has(cur_lang):
                languages.append(cur_lang)
    
    var flow_lang: UpdateLanguagesFlow = UpdateLanguagesFlow.new(self._tolgee, languages)
    flow_lang.completed.connect(self._on_languages_updated)
    flow_lang.run()

func _on_languages_updated(err: Error) -> void:
    if err != OK:
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to upload translations. Language updated failed.", EditorToaster.SEVERITY_ERROR)
        self.completed.emit(FAILED)
        return

    self._tolgee._client.single_step_import(self._tolgee.project_id(), self._params, self._on_import_csv)

func _on_import_csv(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, _body_json: Variant) -> void:
    if result != OK:
        var err_msg: String = str(result)
        push_error("[Tolgee] Failed to upload translations: " + err_msg)
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to upload translations.", EditorToaster.SEVERITY_ERROR, err_msg)
        self.completed.emit(FAILED)
        return
    if response_code != HTTPClient.RESPONSE_OK:
        var err_msg: String = "%s - %s" % [str(response_code), body.get_string_from_utf8()]
        push_error("[Tolgee] Failed to upload translations: " + err_msg)
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to upload translations.", EditorToaster.SEVERITY_ERROR, err_msg)
        self.completed.emit(FAILED)
        return

    EditorInterface.get_editor_toaster().push_toast("[Tolgee] Successfully uploaded translations.")
    self.completed.emit(OK)
