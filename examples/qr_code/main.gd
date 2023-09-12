extends HBoxContainer

const QRCode = preload("res://addons/qr_code/qr_code.gd")

@export var _input_data_text: TextEdit
@export var _encoding: OptionButton
@export var _error_correction: OptionButton
@export var _use_eci: CheckBox
@export var _eci_value: OptionButton
@export var _version: SpinBox
@export var _mask_pattern: SpinBox
@export var _module_px_size: SpinBox

@export var _qr_rect: QRCodeRect

func _ready():
	self._update_values()

func _update_values() -> void:
	var col: int = self._input_data_text.get_caret_column()
	var line: int = self._input_data_text.get_caret_line()
	self._input_data_text.text = self._qr_rect.data
	self._input_data_text.set_caret_column(col)
	self._input_data_text.set_caret_line(line)

	self._version.value = self._qr_rect.version
	self._mask_pattern.value = self._qr_rect.mask_pattern
	self._module_px_size.value = self._qr_rect.module_px_size

func _on_input_data_text_text_changed() -> void:
	self._qr_rect.data = self._input_data_text.text
	self._update_values()

func _on_encoding_item_selected(_index: int) -> void:
	self._qr_rect.mode = self._encoding.get_selected_id() as QRCode.Mode
	if self._qr_rect.mode == QRCode.Mode.BYTE && !self._qr_rect.use_eci:
		self._use_eci.button_pressed = true
		self._use_eci.disabled = true
	else:
		self._use_eci.disabled = false
	self._update_values()

func _on_error_correction_item_selected(_index: int) -> void:
	self._qr_rect.error_correction = self._error_correction.get_selected_id() as QRCode.ErrorCorrection
	self._update_values()

func _on_use_eci_toggled(button_pressed: bool) -> void:
	if !button_pressed && self._qr_rect.mode == QRCode.Mode.BYTE:
		return
	self._qr_rect.use_eci = button_pressed
	self._eci_value.disabled = !button_pressed
	self._update_values()

func _on_eci_value_item_selected(_index: int) -> void:
	self._qr_rect.eci_value = self._eci_value.get_selected_id() as QRCode.ECI
	self._update_values()

func _on_auto_version_toggled(button_pressed: bool) -> void:
	self._qr_rect.auto_version = button_pressed
	self._version.editable = !button_pressed
	self._update_values()

func _on_version_value_changed(value: float) -> void:
	self._qr_rect.version = int(value)
	self._update_values()

func _on_auto_mask_pattern_toggled(button_pressed: bool) -> void:
	self._qr_rect.auto_mask_pattern = button_pressed
	self._mask_pattern.editable = !button_pressed
	self._update_values()

func _on_mask_pattern_value_changed(value: float) -> void:
	self._qr_rect.mask_pattern = int(value)
	self._update_values()

func _on_light_module_color_color_changed(color: Color) -> void:
	self._qr_rect.light_module_color = color
	self._update_values()

func _on_dark_module_color_color_changed(color: Color) -> void:
	self._qr_rect.dark_module_color = color
	self._update_values()

func _on_auto_module_px_size_toggled(button_pressed: bool) -> void:
	self._qr_rect.auto_module_px_size = button_pressed
	self._module_px_size.editable = !button_pressed
	self._update_values()

func _on_module_px_size_value_changed(value: float) -> void:
	self._qr_rect.module_px_size = int(value)
	self._update_values()

func _on_quiet_zone_size_value_changed(value: float) -> void:
	self._qr_rect.quiet_zone_size = int(value)
	self._update_values()
