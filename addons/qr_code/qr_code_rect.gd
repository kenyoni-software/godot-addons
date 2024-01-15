@tool
@icon("res://addons/qr_code/qr_code.svg")
extends TextureRect
class_name QRCodeRect

const QRCode := preload("res://addons/qr_code/qr_code.gd")
const ShiftJIS := preload("res://addons/qr_code/shift_jis.gd")

var _qr: QRCode = QRCode.new()

var mode: QRCode.Mode:
    set = set_mode,
    get = get_mode
var error_correction: QRCode.ErrorCorrection:
    set = set_error_correction,
    get = get_error_correction
## Use Extended Channel Interpretation (ECI).
var use_eci: bool:
    set = set_use_eci,
    get = get_use_eci
## Extended Channel Interpretation (ECI) Value.
var eci_value: int:
    set = set_eci_value,
    get = get_eci_value
var data: Variant = "":
    set = set_data,
    get = get_data
## Use automatically the smallest version possible.
var auto_version: bool = true:
    set = set_auto_version,
    get = get_auto_version
var version: int = 1:
    set = set_version,
    get = get_version
## Use automatically the best mask pattern.
var auto_mask_pattern: bool = true:
    set = set_auto_mask_pattern,
    get = get_auto_mask_pattern
## Used mask pattern.
var mask_pattern = 0:
    set = set_mask_pattern,
    get = get_mask_pattern
var light_module_color: Color = Color.WHITE:
    set = set_light_module_color
var dark_module_color: Color = Color.BLACK:
    set = set_dark_module_color
## Automatically set the module pixel size based on the size.
## Do not use expand mode KEEP_SIZE when using it.
## Turn this off when the QR Code changes or is resized often, as it impacts the performance quite heavily.
var auto_module_px_size: bool = true:
    set = set_auto_module_px_size
## Use that many pixel for one module.
var module_px_size: int = 1:
    set = set_module_px_size
## Use that many modules for the quiet zone. A value of 4 is recommended.
var quiet_zone_size: int = 4:
    set = set_quiet_zone_size

func set_mode(new_mode: QRCode.Mode) -> void:
    self._qr.mode = new_mode
    self.notify_property_list_changed()
    self._update_qr()

func get_mode() -> QRCode.Mode:
    return self._qr.mode

func set_error_correction(new_error_correction: QRCode.ErrorCorrection) -> void:
    self._qr.error_correction = new_error_correction
    self._update_qr()

func get_error_correction() -> QRCode.ErrorCorrection:
    return self._qr.error_correction

func set_use_eci(new_use_eci: bool) -> void:
    self._qr.use_eci = new_use_eci
    self.notify_property_list_changed()
    self._update_qr()

func get_use_eci() -> bool:
    return self._qr.use_eci

func set_eci_value(new_eci_value: int) -> void:
    self._qr.eci_value = new_eci_value
    self.notify_property_list_changed()
    self._update_qr()

func get_eci_value() -> int:
    return self._qr.eci_value

func set_data(new_data: Variant) -> void:
    match self._qr.mode:
        QRCode.Mode.NUMERIC:
            self._qr.put_numeric(new_data)
        QRCode.Mode.ALPHANUMERIC:
            self._qr.put_alphanumeric(new_data)
        QRCode.Mode.BYTE:
            if typeof(new_data) == TYPE_PACKED_BYTE_ARRAY || !self.use_eci:
                self._qr.put_byte(new_data)
                return
            match self.eci_value:
                QRCode.ECI.ISO_8859_1:
                    self._qr.put_byte(new_data.to_ascii_buffer())
                QRCode.ECI.SHIFT_JIS:
                    self._qr.put_byte(ShiftJIS.to_shift_jis_2004_buffer(new_data))
                QRCode.ECI.UTF_8:
                    self._qr.put_byte(new_data.to_utf8_buffer())
                QRCode.ECI.UTF_16:
                    self._qr.put_byte(new_data.to_utf16_buffer())
                QRCode.ECI.US_ASCII:
                    self._qr.put_byte(new_data.to_ascii_buffer())
                _:
                    self._qr.put_byte(new_data)
        QRCode.Mode.KANJI:
            self._qr.put_kanji(new_data)

    self._update_qr()

func get_data() -> Variant:
    var input_data: Variant = self._qr.get_input_data()
    if self.mode == QRCode.Mode.BYTE && self.use_eci:
        match self.eci_value:
            QRCode.ECI.ISO_8859_1:
                return input_data.get_string_from_ascii()
            QRCode.ECI.SHIFT_JIS:
                return ShiftJIS.get_string_from_shift_jis_2004(input_data)
            QRCode.ECI.UTF_8:
                return input_data.get_string_from_utf8()
            QRCode.ECI.UTF_16:
                return input_data.get_string_from_utf16()
            QRCode.ECI.US_ASCII:
                return input_data.get_string_from_ascii()

    return self._qr.get_input_data()

func set_auto_version(new_auto_version: bool) -> void:
    self._qr.auto_version = new_auto_version
    self.notify_property_list_changed()
    self._update_qr()

func get_auto_version() -> bool:
    return self._qr.auto_version

func set_version(new_version: int) -> void:
    self._qr.version = new_version
    self._update_qr()

func get_version() -> int:
    return self._qr.version

func set_auto_mask_pattern(new_auto_mask_pattern: bool) -> void:
    self._qr.auto_mask_pattern = new_auto_mask_pattern
    self.notify_property_list_changed()
    self._update_qr()

func get_auto_mask_pattern() -> bool:
    return self._qr.auto_mask_pattern

func set_mask_pattern(new_mask_pattern: int) -> void:
    self._qr.mask_pattern = new_mask_pattern
    self._update_qr()

func get_mask_pattern() -> int:
    return self._qr.mask_pattern

func set_light_module_color(new_light_module_color: Color) -> void:
    light_module_color = new_light_module_color
    self._update_qr()

func set_dark_module_color(new_dark_module_color: Color) -> void:
    dark_module_color = new_dark_module_color
    self._update_qr()

func set_auto_module_px_size(new_auto_module_px_size: bool) -> void:
    auto_module_px_size = new_auto_module_px_size
    self.notify_property_list_changed()
    self.update_configuration_warnings()
    self._update_qr()

func set_module_px_size(new_module_px_size: int) -> void:
    module_px_size = new_module_px_size
    if !self.auto_module_px_size:
        self._update_qr()

func set_quiet_zone_size(new_quiet_zone_size: int) -> void:
    quiet_zone_size = maxi(0, new_quiet_zone_size)
    self._update_qr()

func _init() -> void:
    if self.texture != null:
        self._update_qr()

func _set(property: StringName, value: Variant) -> bool:
    if property == "expand_mode":
        self.update_configuration_warnings()
        
    return false

func _get_property_list() -> Array[Dictionary]:
    var eci_value_prop: Dictionary = {
        "name": "eci_value",
        "type": TYPE_INT,
        "usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE,
        "hint": PROPERTY_HINT_ENUM,
        "hint_string": "Code Page 437:2,ISO 8859-1:3,ISO 8859-2:4,ISO 8859-3:5,ISO 8859-4:6,ISO 8859-5:7,ISO 8859-6:8,ISO 8859-7:9,ISO 8859-8:10,ISO 8859-9:11,ISO 8859-10:12,ISO 8859-11:13,ISO 8859-12:14,ISO 8859-13:15,ISO 8859-14:16,ISO 8859-15:17,ISO 8859-16:18,Shift JIS:20,Windows 1250:21,Windows 1251:22,Windows 1252:23,Windows 1256:24,UTF-16:25,UTF-8:26,US ASCII:27,BIG 5:28,GB 18030:29,EUC KR:30"
    }
    if !self.use_eci:
        eci_value_prop["usage"] = (eci_value_prop["usage"] | PROPERTY_USAGE_READ_ONLY) & ~PROPERTY_USAGE_STORAGE

    var data_prop: Dictionary = {
        "name": "data",
        "usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE,
    }
    match self.mode:
        QRCode.Mode.NUMERIC:
            data_prop["type"] = TYPE_STRING
        QRCode.Mode.ALPHANUMERIC, QRCode.Mode.KANJI:
            data_prop["type"] = TYPE_STRING
            data_prop["hint"] = PROPERTY_HINT_MULTILINE_TEXT
        QRCode.Mode.BYTE:
            # these encoding is nativeley supported
            if self.use_eci && self.eci_value in [QRCode.ECI.ISO_8859_1, QRCode.ECI.SHIFT_JIS, QRCode.ECI.UTF_8, QRCode.ECI.UTF_16, QRCode.ECI.US_ASCII]:
                data_prop["type"] = TYPE_STRING
                data_prop["hint"] = PROPERTY_HINT_MULTILINE_TEXT
            else:
                data_prop["type"] = TYPE_PACKED_BYTE_ARRAY

    var version_prop: Dictionary = {
        "name": "version",
        "type": TYPE_INT,
        "usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE,
        "hint": PROPERTY_HINT_RANGE,
        "hint_string": "1,40"
    }
    if self.auto_version:
        version_prop["usage"] = (version_prop["usage"] | PROPERTY_USAGE_READ_ONLY) & ~PROPERTY_USAGE_STORAGE

    var mask_prop: Dictionary = {
        "name": "mask_pattern",
        "type": TYPE_INT,
        "usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE,
        "hint": PROPERTY_HINT_RANGE,
        "hint_string": "0,7"
    }
    if self.auto_mask_pattern:
        mask_prop["usage"] = (mask_prop["usage"] | PROPERTY_USAGE_READ_ONLY) & ~PROPERTY_USAGE_STORAGE
    
    var module_px_size_prop: Dictionary = {
        "name": "module_px_size",
        "type": TYPE_INT,
        "usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE,
        "hint": PROPERTY_HINT_RANGE,
        "hint_string": "1,1,or_greater"
    }
    if self.auto_module_px_size:
        module_px_size_prop["usage"] = (module_px_size_prop["usage"] | PROPERTY_USAGE_READ_ONLY) & ~PROPERTY_USAGE_STORAGE

    return [
        {
            "name": "mode",
            "type": TYPE_INT,
            "usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE,
            "hint": PROPERTY_HINT_ENUM,
            "hint_string": "Numeric:1,Alphanumeric:2,Byte:4,Kanji:8"
        },
        {
            "name": "error_correction",
            "type": TYPE_INT,
            "usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE,
            "hint": PROPERTY_HINT_ENUM,
            "hint_string": "Low:1,Medium:0,Quartile:3,High:2"
        },
        {
            "name": "use_eci",
            "type": TYPE_BOOL,
            "usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE,
        },
        eci_value_prop,
        data_prop,
        {
            "name": "auto_version",
            "type": TYPE_BOOL,
            "usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE,
        },
        version_prop,
        {
            "name": "auto_mask_pattern",
            "type": TYPE_BOOL,
            "usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE,
        },
        mask_prop,
        {
            "name": "Appearance",
            "type": TYPE_NIL,
            "usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_GROUP,
        },
        {
            "name": "light_module_color",
            "type": TYPE_COLOR,
            "usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE ,
        },
        {
            "name": "dark_module_color",
            "type": TYPE_COLOR,
            "usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE ,
        },
        {
            "name": "auto_module_px_size",
            "type": TYPE_BOOL,
            "usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE,
        },
        module_px_size_prop,
        {
            "name": "quiet_zone_size",
            "type": TYPE_INT,
            "usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE,
            "hint_string": "0,1,or_greater",
        },
    ]

func _property_can_revert(property: StringName) -> bool:
    return property in ["eci_value", "auto_version", "auto_mask_pattern", "light_module_color", "dark_module_color", "auto_module_px_size", "quiet_zone_size"]

func _property_get_revert(property: StringName) -> Variant:
    match property:
        "eci_value":
            return QRCode.ECI.ISO_8859_1
        "auto_version":
            return true
        "auto_mask_pattern":
            return true
        "light_module_color":
            return Color.WHITE
        "dark_module_color":
            return Color.BLACK
        "auto_module_px_size":
            return true
        "quiet_zone_size":
            return 4
        _:
            return null

func _get_configuration_warnings() -> PackedStringArray:
    if self.auto_module_px_size && self.expand_mode == EXPAND_KEEP_SIZE:
        return ["Do not use auto module px size AND keep size expand mode."]
    return []

func _notification(what: int) -> void:
    match what:
        NOTIFICATION_RESIZED:
            if self.auto_module_px_size:
                self._update_qr()

func _update_qr() -> void:
    if self.auto_module_px_size:
        self.module_px_size = mini(self.size.x, self.size.y) / (self._qr.get_module_count() + 2 * self.quiet_zone_size)
    self.texture = ImageTexture.create_from_image(self._qr.generate_image(self.module_px_size, self.light_module_color, self.dark_module_color, self.quiet_zone_size))
