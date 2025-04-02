extends HTTPRequest

## body_json will be empty dictionary if the response is empty
## and null if the response is not a valid json
signal completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, body_json: Variant)

func _init():
    self.use_threads = true
    self.timeout = 5
    self.request_completed.connect(self._on_complete)

func _on_complete(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
    self.queue_free()
    if body.is_empty():
        self.completed.emit(result, response_code, headers, body, {})
        return
    var json_parser: JSON = JSON.new()
    var err: Error = json_parser.parse(body.get_string_from_utf8())
    if err != OK:
        self.completed.emit(result, response_code, headers, body, null)
        push_error("[Tolgee] Failed to parse json: '%s'", [json_parser.get_error_message()])
        return
    self.completed.emit(result, response_code, headers, body, json_parser.data)
