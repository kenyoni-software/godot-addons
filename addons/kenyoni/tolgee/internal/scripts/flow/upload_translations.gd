extends "res://addons/kenyoni/tolgee/internal/scripts/flow/flow.gd"

const Client := preload("res://addons/kenyoni/tolgee/internal/scripts/client.gd")
const UpdateLanguagesFlow := preload("res://addons/kenyoni/tolgee/internal/scripts/flow/update_languages.gd")

func _init(tolgee: Tolgee) -> void:
    super._init(tolgee)

var _params: Client.PostSingleStepImportParams = null
var _languages: Array[String] = []

## OVERRIDE
## TODO: simplify and clean up
func run() -> void:
    super.run()

    self._languages = []
    self._params = Client.PostSingleStepImportParams.new()

    for tr_cfg: Dictionary in self._tolgee.files():
        # read input file and add it
        var input_path: String = tr_cfg.get(Tolgee.FILES_KEY_INPUT_PATH, "")
        var file_data: PackedByteArray = FileAccess.get_file_as_bytes(input_path)
        if file_data.size() == 0 && FileAccess.get_open_error() != OK:
            var err_msg: String = "Failed to open file: '%s' - %s" % [input_path, error_string(FileAccess.get_open_error())]
            push_error("[Tolgee] Failed to collect translations: " + err_msg)
            EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to collect translations.", EditorToaster.SEVERITY_ERROR, err_msg)
            self.completed.emit(FAILED)
            return

        var input_file_id: String = input_path.validate_filename()
        self._params.files.append(Client.PostSingleStepImportFile.new(input_file_id, file_data))
        match (tr_cfg.get(Tolgee.FILES_KEY_INPUT_PATH, "") as String).get_extension():
            "csv":
                if self._collect_csv(input_file_id, tr_cfg) != OK:
                    return
            "pot":
                if self._collect_pot(input_file_id, tr_cfg) != OK:
                    return

    self._params.convert_placeholders_to_icu = true
    self._params.create_new_keys = ProjectSettings.get_setting(Tolgee.CFG_KEY_UPLOAD_ADD_NEW, true)
    self._params.remove_other_keys = ProjectSettings.get_setting(Tolgee.CFG_KEY_UPLOAD_REMOVE_MISSING, true)
    if ProjectSettings.get_setting(Tolgee.CFG_KEY_UPLOAD_OVERRIDE_EXISTING, true):
        self._params.force_mode = "OVERRIDE"
    else:
        self._params.force_mode = "KEEP"

    var flow_lang: UpdateLanguagesFlow = UpdateLanguagesFlow.new(self._tolgee, self._languages)
    flow_lang.completed.connect(self._on_languages_updated)
    flow_lang.run()

func _collect_csv(input_file_id: String, tr_cfg: Dictionary) -> Error:
    var file_mapping: Client.PostSingleStepImportFileMapping = Client.PostSingleStepImportFileMapping.new(input_file_id)
    file_mapping.format = "CSV_" + (tr_cfg.get(Tolgee.FILES_KEY_PLACEHOLDER, "") as String).to_upper()
    file_mapping.language_tag = "_"
    file_mapping.namespace_str = tr_cfg.get(Tolgee.FILES_KEY_NAMESPACE, "")
    self._params.file_mappings.append(file_mapping)

    # collect languages
    var input_path: String = tr_cfg.get(Tolgee.FILES_KEY_INPUT_PATH, "")
    var file: FileAccess = FileAccess.open(input_path, FileAccess.READ)
    if file == null:
        var err_msg: String = "Failed to open file: '%s' - %s" % [input_path, error_string(FileAccess.get_open_error())]
        push_error("[Tolgee] Failed to collect translations: " + err_msg)
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to collect translations.", EditorToaster.SEVERITY_ERROR, err_msg)
        self.completed.emit(FAILED)
        return FAILED
    var cur_languages: PackedStringArray = file.get_csv_line()
    file.close()
    cur_languages.remove_at(0)
    for cur_lang: String in cur_languages:
        if !self._languages.has(cur_lang):
            self._languages.append(cur_lang)
    return OK

func _collect_pot(input_file_id: String, tr_cfg: Dictionary) -> Error:
    # create file mapping of pot file
    var file_mapping: Client.PostSingleStepImportFileMapping = Client.PostSingleStepImportFileMapping.new(input_file_id)
    file_mapping.format = "PO_" + (tr_cfg.get(Tolgee.FILES_KEY_PLACEHOLDER, "") as String).to_upper()
    file_mapping.namespace_str = tr_cfg.get(Tolgee.FILES_KEY_NAMESPACE, "")
    # TODO: POT files are not supported by Tolgee (only PO files)
    # so we have to define a language placeholder
    if !self._languages.has("en"):
            self._languages.append("en")
    file_mapping.language_tag = "en"
    self._params.file_mappings.append(file_mapping)

    # add translations from PO files
    var file_name_prefix: String = tr_cfg.get(Tolgee.FILES_KEY_INPUT_PATH, "").get_file().get_basename()
    var output_path: String = tr_cfg.get(Tolgee.FILES_KEY_OUTPUT_PATH, "")
    for file: String in DirAccess.get_files_at(tr_cfg.get(Tolgee.FILES_KEY_OUTPUT_PATH, "") as String):
        if file.get_extension() != "po" || !file.begins_with(file_name_prefix):
            continue

        var po_file_path: String = output_path.path_join(file)
        # add PO file
        var po_file_id: String = po_file_path.validate_filename()
        var po_file_data: PackedByteArray = FileAccess.get_file_as_bytes(po_file_path)
        if po_file_data.size() == 0 && FileAccess.get_open_error() != OK:
            var err_msg: String = "Failed to open file: '%s' - %s" % [po_file_path, error_string(FileAccess.get_open_error())]
            push_error("[Tolgee] Failed to collect translations: " + err_msg)
            EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to collect translations.", EditorToaster.SEVERITY_ERROR, err_msg)
            self.completed.emit(FAILED)
            return FAILED

        # add PO file mapping
        self._params.files.append(Client.PostSingleStepImportFile.new(po_file_id, po_file_data))
        var po_file_mapping: Client.PostSingleStepImportFileMapping = Client.PostSingleStepImportFileMapping.new(po_file_id)
        po_file_mapping.format = "PO_" + (tr_cfg.get(Tolgee.FILES_KEY_PLACEHOLDER, "") as String).to_upper()
        var tra: Translation = ResourceLoader.load(po_file_path, "Translation")
        if tra == null:
            var err_msg: String = "Failed to load file: '%s'" % po_file_path
            push_error("[Tolgee] Failed to collect translations: " + err_msg)
            EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to collect translations.", EditorToaster.SEVERITY_ERROR, err_msg)
            self.completed.emit(FAILED)
            return FAILED
        if !self._languages.has(tra.locale):
            self._languages.append(tra.locale)
        po_file_mapping.language_tag = tra.locale
        po_file_mapping.namespace_str = tr_cfg.get(Tolgee.FILES_KEY_NAMESPACE, "")
        self._params.file_mappings.append(po_file_mapping)
    return OK

func _on_languages_updated(err: Error) -> void:
    if err != OK:
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to upload translations. Language updated failed.", EditorToaster.SEVERITY_ERROR)
        self.completed.emit(FAILED)
        return

    self._tolgee._client.single_step_import(self._tolgee.project_id(), self._params, self._on_import_finished)

func _on_import_finished(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, _body_json: Variant) -> void:
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
