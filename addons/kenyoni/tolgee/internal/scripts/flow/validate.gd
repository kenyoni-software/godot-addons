extends "res://addons/kenyoni/tolgee/internal/scripts/flow/flow.gd"

func _init(tolgee: Tolgee) -> void:
    super._init(tolgee)

## OVERRIDE
func run() -> void:
    self._tolgee.pre_validation.emit()
    super.run()
    self._tolgee._client.get_api_keys_current_permissions(self._on_api_keys_permissions)

func _on_api_keys_permissions(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, body_json: Variant) -> void:
    if result != OK:
        self._tolgee._clear_project()
        var err_msg: String = str(result)
        push_error("[Tolgee] Failed to validate API key: " + err_msg)
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to validate API key.", EditorToaster.SEVERITY_ERROR, err_msg)
        self._tolgee.validated.emit("Failed to validate API key: " + str(result))
        self.completed.emit(FAILED)
        return
    if response_code != HTTPClient.RESPONSE_OK:
        self._tolgee._clear_project()
        var err_msg: String = "%s - %s" % [str(response_code), body.get_string_from_utf8()]
        push_error("[Tolgee] Failed to validate API key: " + err_msg)
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to validate API key.", EditorToaster.SEVERITY_ERROR, err_msg)
        self._tolgee.validated.emit("Failed to validate API key: " + str(response_code) + " | " + body.get_string_from_utf8())
        self.completed.emit(FAILED)
        return

    self._tolgee._api_key_scopes = body_json["scopes"]
    self._tolgee._client.get_project(body_json["project"]["id"] as int, self._on_project_details)

func _on_project_details(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, body_json: Variant) -> void:
    if result != OK:
        self._tolgee._clear_project()
        var err_msg: String = str(result)
        push_error("[Tolgee] Failed to retrieve project information: " + err_msg)
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to retrieve project information.", EditorToaster.SEVERITY_ERROR, err_msg)
        self._tolgee.validated.emit("Failed to retrieve project information: " + str(result))
        self.completed.emit(FAILED)
        return
    if response_code != HTTPClient.RESPONSE_OK:
        self._tolgee._clear_project()
        var err_msg: String = "%s - %s" % [str(response_code), body.get_string_from_utf8()]
        push_error("[Tolgee] Failed to retrieve project information: " + err_msg)
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to retrieve project information.", EditorToaster.SEVERITY_ERROR, err_msg)
        self._tolgee.validated.emit("Failed to retrieve project information: " + str(response_code) + " | " + body.get_string_from_utf8())
        self.completed.emit(FAILED)
        return

    self._tolgee._project = body_json
    self._tolgee.validated.emit("")
    self.completed.emit(OK)
