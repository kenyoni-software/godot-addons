extends HBoxContainer

const QRCode = preload("res://addons/qr_code/qr_code.gd")

@export var _input_data_text: TextEdit
@export var _encoding: OptionButton
@export var _error_correction: OptionButton
@export var _eci_indicator: OptionButton
@export var _auto_version: CheckBox
@export var _version: SpinBox
@export var _auto_mask_pattern: CheckBox
@export var _mask_pattern: SpinBox
@export var _light_module_color: ColorPickerButton
@export var _dark_module_color: ColorPickerButton
@export var _auto_module_px_size: CheckBox
@export var _module_px_size: SpinBox
@export var _quiet_zone_size: SpinBox

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
	self._update_values()

func _on_error_correction_item_selected(_index: int) -> void:
	self._qr_rect.error_correction = self._error_correction.get_selected_id() as QRCode.ErrorCorrection
	self._update_values()

func _on_eci_indicator_item_selected(_index: int) -> void:
	self._qr_rect.eci_value = self._eci_indicator.get_selected_id() as QRCode.ECI
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

func _on_quiet_zone_size_value_changed(value: float):
	self._qr_rect.quiet_zone_size = int(value)
	self._update_values()
