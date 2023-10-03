extends RefCounted

var _data: PackedByteArray = []

func duplicate():
    var dup = new()
    dup._data = self._data.duplicate()
    return dup

func resize(size: int) -> void:
    self._data.resize(size)

func size() -> int:
    return self._data.size()

func clear() -> void:
    return self._data.clear()

func get_array() -> PackedByteArray:
    return self._data

func to_byte_array() -> PackedByteArray:
    var byte_arr: PackedByteArray = []

    var cur_byte: int = 0
    for idx: int in range(self._data.size()):
        var byte_idx: int = 7 - idx % 8
        if self._data[idx]:
            cur_byte = _set_state(cur_byte, byte_idx)
        if (idx != 0 && byte_idx == 0) || idx == self._data.size() - 1:
            byte_arr.append(cur_byte)
            cur_byte = 0
    return byte_arr

func prepend_bit(bit: bool) -> void:
    self._data.insert(0, int(bit))

func append_bit(bit: bool) -> void:
    self._data.append(int(bit))

func append_stream(stream) -> void:
    self._data.append_array(stream.get_array())

func append_byte_array(arr: PackedByteArray) -> void:
    for val: int in arr:
        self.append(val, 8)

func prepend(value: int, total_bits: int) -> void:
    for idx: int in range(total_bits - 1, -1, -1):
        self._data.insert(0, int(get_state(value, idx)))

func append(value: int, total_bits: int) -> void:
    for idx: int in range(total_bits - 1, -1, -1):
        self._data.append(int(get_state(value, idx)))

func set_bit(idx: int, bit: bool) -> void:
    self._data[idx] = int(bit)

func get_bit(idx: int) -> bool:
    return bool(self._data[idx])

func _to_string() -> String:
    var val: String = ""
    for idx: int in range(self._data.size()):
        if (idx + 1) % 8 == 1:
            val += "["
        val += str(self._data[idx])
        if (idx + 1) % 8 == 0:
            val += "]"
        if (idx + 1) % 4 == 0:
            val += " "
    val = val.strip_edges()
    if val[-1] != "]":
        val += "]"
    return val

static func _set_state(value: int, idx: int) -> int:
    return value | (1 << idx)

static func get_state(value: int, idx: int) -> bool:
    return (value & (1 << idx))

static func toggle_state(value: int, idx: int) -> int:
    return value ^ (1 << idx)
