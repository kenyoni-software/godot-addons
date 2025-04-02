extends "res://addons/kenyoni/tolgee/internal/scripts/flow/flow.gd"

var _callback: Callable

## callback: Callable[String]
func _init(tolgee: Tolgee, callback: Callable) -> void:
    super._init(tolgee)
    self._callback = callback

## OVERRIDE
func run() -> void:
    self._tolgee._client.get_api_keys_current_permissions(self._on_validate_1)

### callback: Callable[String]
func _on_validate_1(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, body_json: Variant) -> void:
    if result != OK:
        self._tolgee._clear_project()
        self._callback.call("Failed to validate Tolgee: " + str(result))
        self.completed.emit(FAILED)
        return
    if response_code != HTTPClient.RESPONSE_OK:
        self._tolgee._clear_project()
        self._callback.call("Failed to validate Tolgee: " + str(response_code) + " | " + body.get_string_from_utf8())
        self.completed.emit(FAILED)
        return

    self._tolgee._api_key_scopes = body_json["scopes"]
    self._tolgee._client.get_project(body_json["project"]["id"] as int, self._on_validate_2)

## callback: Callable[String]
func _on_validate_2(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, body_json: Variant) -> void:
    if result != OK:
        self._tolgee._clear_project()
        self._callback.call("Failed to validate Tolgee: " + str(result))
        self.completed.emit(FAILED)
        return
    if response_code != HTTPClient.RESPONSE_OK:
        self._tolgee._clear_project()
        self._callback.call("Failed to validate Tolgee: " + str(response_code) + " | " + body.get_string_from_utf8())
        self.completed.emit(FAILED)
        return

    self._tolgee._project = body_json
    self._callback.call("")
    self._tolgee.linked.emit(true)
    self.completed.emit(OK)
