extends "res://addons/kenyoni/tolgee/internal/scripts/flow/flow.gd"

const Client := preload("res://addons/kenyoni/tolgee/internal/scripts/client.gd")

var _params: Client.PostSingleStepImportParams = Client.PostSingleStepImportParams.new()

func _init(tolgee: Tolgee, csv_files: Array[PackedByteArray], csv_filepaths: Array[String], placeholder: String) -> void:
    super._init(tolgee)

    for idx: int in range(csv_files.size()):
        var file_path: String = csv_filepaths[idx]
        var file_data: PackedByteArray = csv_files[idx]
        self._params.files.append(Client.PostSingleStepImportFile.new(file_path.get_file(), file_data))
        var file_mapping: Client.PostSingleStepImportFileMapping = Client.PostSingleStepImportFileMapping.new(file_path.get_file())
        file_mapping.format = "CSV_" + placeholder.to_upper()
        file_mapping.namespace_str = ResourceUID.get_id_path(ResourceUID.text_to_id(file_path))
        self._params.file_mappings.append(file_mapping)

    self._params.convert_placeholders_to_icu = true
    self._params.create_new_keys = true
    self._params.remove_other_keys = true
    self._params.force_mode = "KEEP"

## OVERRIDE
func run() -> void:
    self._tolgee._client.post_single_step_import(self._tolgee.project_id(), self._params, self._on_push_csv_translation_keys)

func _on_push_csv_translation_keys(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, _body_json: Variant) -> void:
    if result != OK:
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to push translation keys: " + str(result), EditorToaster.SEVERITY_ERROR)
        return
    if response_code != HTTPClient.RESPONSE_OK:
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to push translation keys: " + str(response_code) + " | " + body.get_string_from_utf8(), EditorToaster.SEVERITY_ERROR)
        return

    EditorInterface.get_editor_toaster().push_toast("[Tolgee] Successfully pushed translation keys.")
