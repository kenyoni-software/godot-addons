@tool
extends VBoxContainer

const Tolgee := preload("res://addons/kenyoni/tolgee/internal/scripts/tolgee.gd")

@export var _status_errors: Label

@export var _project_name: LinkButton
@export var _check_status_button: Button
@export var _status_checking: Control
@export var _workflow: Label

@export var _push_keys: Button
@export var _pull_translations: Button
@export var _push_translations: Button

func _ready() -> void:
    self._status_errors.add_theme_color_override(&"font_color", self.get_theme_color(&"error_color", &"Editor"))
    self._check_status_button.icon = self.get_theme_icon(&"Reload", &"EditorIcons")

    self._update_ui()

    self._push_keys.pressed.connect(Tolgee.interface().push_translation_keys)

    self._check_status_button.pressed.connect(self._on_check_status_button_pressed)
    Tolgee.interface().linked.connect(self._on_client_linked)
    ProjectSettings.settings_changed.connect(self._update_ui)

func _update_ui() -> void:
    self._push_keys.disabled = !Tolgee.interface().is_operating()
    self._pull_translations.disabled = !Tolgee.interface().is_operating()
    self._push_translations.disabled = !Tolgee.interface().is_operating()
    self._workflow.text = Tolgee.interface().localization()
    if Tolgee.interface().is_operating():
        self._project_name.text = Tolgee.interface().project_name()
        self._project_name.uri = Tolgee.interface().project_uri()
        self._project_name.underline = LinkButton.UNDERLINE_MODE_ALWAYS
    else:
        self._project_name.text = "-"
        self._project_name.uri = ""
        self._project_name.underline = LinkButton.UNDERLINE_MODE_NEVER
    var cfg_warnings: PackedStringArray = Tolgee.interface().config_warnings()
    self._status_errors.visible = cfg_warnings.size() > 0
    self._status_errors.text = "\n".join(cfg_warnings)

func _on_client_validated(err_msg: String) -> void:
    self._status_checking.visible = false
    self._update_ui()

    var errors: Array[String] = []
    if err_msg != "":
        errors.append(err_msg)
    errors.append_array(Tolgee.interface().config_warnings())
    self._status_errors.visible = errors.size() > 0
    self._status_errors.text = "\n".join(errors)

func _on_client_linked(_is_linked: bool) -> void:
    self._update_ui()

func _on_check_status_button_pressed() -> void:
    self._status_checking.visible = true
    Tolgee.interface().validate(self._on_client_validated)
