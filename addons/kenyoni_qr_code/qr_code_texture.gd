@tool
@icon("qr_code.svg")
extends ImageTexture
class_name QRCodeTexture

const QRCode = preload("qr_code.gd")

var _qr: QRCode = QRCode.new()

@export var error_correction: QRCode.ErrorCorrection = QRCode.ErrorCorrection.LOW:
    set = set_error_correction
@export var mode: QRCode.Mode = QRCode.Mode.NUMERIC:
    set = set_mode
@export_range(1, 40) var version: int = 1:
    set = set_version
@export_multiline var data: String = "":
    set = set_data
@export_range(-1, 7) var mask_pattern: int = -1:
    set = set_mask_pattern
@export var module_px_size: int = 1:
    set = set_module_px_size

func set_error_correction(new_error_correction: QRCode.ErrorCorrection) -> void:
    self._qr.error_correction = new_error_correction
    error_correction = self._qr.error_correction
    self._create_qr()

func set_mode(new_mode: QRCode.Mode) -> void:
    self._qr.mode = new_mode
    mode = self._qr.mode
    self._create_qr()

func set_version(new_version: int) -> void:
    self._qr.version = new_version
    version = self._qr.version
    self._create_qr()

func set_data(new_data: String) -> void:
    self._qr.data = new_data
    data = self._qr.data
    self._create_qr()

func set_mask_pattern(new_mask_pattern: int) -> void:
    self._qr.mask_pattern = new_mask_pattern
    mask_pattern = self._qr.mask_pattern
    self._create_qr()

func set_module_px_size(new_module_px_size: int) -> void:
    module_px_size = max(1, new_module_px_size)
    self._create_qr()

func _init() -> void:
    self._create_qr()

func _create_qr() -> void:
    self.set_image(self._qr.create_image(self.module_px_size))
