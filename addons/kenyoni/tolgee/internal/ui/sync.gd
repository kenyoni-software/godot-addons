@tool
extends VBoxContainer

const Tolgee := preload("res://addons/kenyoni/tolgee/internal/scripts/tolgee.gd")

@export var _download_translations: Button
@export var _upload_translations: Button
@export var _add_new_translations_checkbox: CheckBox
@export var _remove_missing_translations_checkbox: CheckBox
@export var _override_existing_translations_checkbox: CheckBox

func _ready() -> void:
    self._update_ui()

    self._add_new_translations_checkbox.toggled.connect(func(toggled: bool) -> void: ProjectSettings.set_setting(Tolgee.CFG_KEY_UPLOAD_ADD_NEW, toggled))
    self._remove_missing_translations_checkbox.toggled.connect(func(toggled: bool) -> void: ProjectSettings.set_setting(Tolgee.CFG_KEY_UPLOAD_REMOVE_MISSING, toggled))
    self._override_existing_translations_checkbox.toggled.connect(func(toggled: bool) -> void: ProjectSettings.set_setting(Tolgee.CFG_KEY_UPLOAD_OVERRIDE_EXISTING, toggled))
    self._download_translations.pressed.connect(Tolgee.interface().download_translations)
    self._upload_translations.pressed.connect(Tolgee.interface().upload_translations)

    Tolgee.interface().pre_validation.connect(self._update_ui)
    Tolgee.interface().validated.connect(self._on_client_validated)

func _update_ui() -> void:
    self._download_translations.disabled = !Tolgee.interface().is_operating()
    self._upload_translations.disabled = !Tolgee.interface().is_operating()
    self._override_existing_translations_checkbox.set_pressed_no_signal(ProjectSettings.get_setting(Tolgee.CFG_KEY_UPLOAD_OVERRIDE_EXISTING, false))
    self._remove_missing_translations_checkbox.set_pressed_no_signal(ProjectSettings.get_setting(Tolgee.CFG_KEY_UPLOAD_REMOVE_MISSING, false))
    self._add_new_translations_checkbox.set_pressed_no_signal(ProjectSettings.get_setting(Tolgee.CFG_KEY_UPLOAD_ADD_NEW, false))

func _on_client_validated(_err_msg: String) -> void:
    self._update_ui()
