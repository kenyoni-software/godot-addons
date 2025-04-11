extends RefCounted

## standard line ending for HTTP multipart
const CRLF: String = "\r\n"

class Part:
    extends RefCounted

    var name: String
    # PackedByteArray if filename is set, otherwise String
    # null is not allowed
    var data: Variant
    # optional
    var filename: String
    # optional, only used if filename is set
    var content_type: String

var _boundary: String
var _content_type_header: String
var _body: PackedByteArray

var _parts: Array[Part] = []

func _init(form_parts: Array[Part] = []) -> void:
    self._parts = form_parts

func add(part: Part) -> void:
    self._parts.append(part)

func body() -> PackedByteArray:
    return self._body

func content_type_header() -> String:
    return self._content_type_header

func generate() -> Error:
    self._boundary = self._generate_boundary()
    self._content_type_header = "multipart/form-data; boundary=" + self._boundary
    return self._build_payload()

## generates a reasonably unique boundary string
func _generate_boundary() -> String:
    return "GodotMultipartBoundary%s%s" % [Time.get_ticks_usec(), randi() % 900000 + 100000]

# builds the complete multipart/form-data body as PackedByteArray
func _build_payload() -> Error:
    var payload: PackedByteArray = PackedByteArray()
    var boundary_bytes: PackedByteArray = ("--" + self._boundary).to_utf8_buffer()
    var crlf_bytes: PackedByteArray = CRLF.to_utf8_buffer()

    # process each part in the array
    for idx: int in range(self._parts.size()):
        var part: Part = self._parts[idx]

        if part.name == "":
            push_error("MultiPartFormData warning: skipping item at index %d due to missing or invalid 'name' (string)." % idx, " item: ", part)
            continue

        if part.filename != "":
            if part.content_type == "":
                part.content_type = "application/octet-stream"

            # start of file part
            payload.append_array(boundary_bytes)
            payload.append_array(crlf_bytes)

            # content-disposition header for file
            var disposition: String = "Content-Disposition: form-data; name=\"%s\"; filename=\"%s\"" % [part.name, part.filename]
            payload.append_array(disposition.to_utf8_buffer())
            payload.append_array(crlf_bytes)

            # content-type header for file
            var type_header: String = "Content-Type: " + part.content_type
            payload.append_array(type_header.to_utf8_buffer())
            payload.append_array(crlf_bytes)

            # extra CRLF before body
            payload.append_array(crlf_bytes)

            # file body
            payload.append_array(part.data as PackedByteArray)
            # add CRLF after the data
            payload.append_array(crlf_bytes)
        else:
            # start of text part
            payload.append_array(boundary_bytes)
            payload.append_array(crlf_bytes)

            # content-disposition header for text field
            var disposition: String = "Content-Disposition: form-data; name=\"" + part.name + "\""
            payload.append_array(disposition.to_utf8_buffer())
            payload.append_array(crlf_bytes)

            # extra CRLF before body
            payload.append_array(crlf_bytes)

            # text body (ensure UTF-8)
            payload.append_array((part.data as String).to_utf8_buffer())
            # add CRLF after the data
            payload.append_array(crlf_bytes)

    # final boundary
    # only add final boundary if any parts were successfully added
    if !payload.is_empty():
        payload.append_array(boundary_bytes)
        # end marker
        payload.append_array("--".to_utf8_buffer())
        payload.append_array(crlf_bytes)

    self._body = payload
    return OK
