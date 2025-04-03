extends "res://addons/kenyoni/tolgee/internal/scripts/flow/flow.gd"

var _callback: Callable

## callback: Callable[String]
func _init(tolgee: Tolgee, callback: Callable) -> void:
    super._init(tolgee)
    self._callback = callback

## OVERRIDE
func run() -> void:
    super.run()
    self._tolgee._client.get_api_keys_current_permissions(self._on_api_keys_permissions)

### callback: Callable[String]
func _on_api_keys_permissions(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, body_json: Variant) -> void:
    if result != OK:
        self._tolgee._clear_project()
        var err_msg: String = str(result)
        push_error("[Tolgee] Failed to validate API key: " + err_msg)
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to validate API key.", EditorToaster.SEVERITY_ERROR, err_msg)
        self._callback.call("Failed to validate API key: " + str(result))
        self.completed.emit(FAILED)
        return
    if response_code != HTTPClient.RESPONSE_OK:
        self._tolgee._clear_project()
        var err_msg: String = "%s - %s" % [str(response_code), body.get_string_from_utf8()]
        push_error("[Tolgee] Failed to validate API key: " + err_msg)
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to validate API key.", EditorToaster.SEVERITY_ERROR, err_msg)
        self._callback.call("Failed to validate API key: " + str(response_code) + " | " + body.get_string_from_utf8())
        self.completed.emit(FAILED)
        return

    self._tolgee._api_key_scopes = body_json["scopes"]
    self._tolgee._client.get_project(body_json["project"]["id"] as int, self._on_project_details)

## callback: Callable[String]
func _on_project_details(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, body_json: Variant) -> void:
    if result != OK:
        self._tolgee._clear_project()
        var err_msg: String = str(result)
        push_error("[Tolgee] Failed to retrieve project information: " + err_msg)
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to retrieve project information.", EditorToaster.SEVERITY_ERROR, err_msg)
        self.completed.emit(FAILED)
        return
    if response_code != HTTPClient.RESPONSE_OK:
        self._tolgee._clear_project()
        var err_msg: String = "%s - %s" % [str(response_code), body.get_string_from_utf8()]
        push_error("[Tolgee] Failed to retrieve project information: " + err_msg)
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to retrieve project information.", EditorToaster.SEVERITY_ERROR, err_msg)
        self.completed.emit(FAILED)
        return

    self._tolgee._project = body_json
    self._callback.call("")
    self._tolgee.linked.emit(true)
    self.completed.emit(OK)
