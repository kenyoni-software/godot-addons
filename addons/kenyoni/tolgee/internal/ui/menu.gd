@tool
extends VBoxContainer

const Tolgee := preload("res://addons/kenyoni/tolgee/internal/scripts/tolgee.gd")

@export var _status_errors: Label

@export var _project_name: LinkButton
@export var _check_status_button: Button
@export var _status_checking: Control
@export var _enable_namespaces_button: Button

@export var _tab_container: TabContainer

func _ready() -> void:
    self._status_errors.add_theme_color_override(&"font_color", self.get_theme_color(&"error_color", &"Editor"))
    self._check_status_button.icon = self.get_theme_icon(&"Reload", &"EditorIcons")
    self._tab_container.set_tab_title(0, "Sync")
    self._tab_container.set_tab_title(1, "Settings")

    self._update_ui()

    self._check_status_button.pressed.connect(self._on_check_status_button_pressed)
    self._enable_namespaces_button.pressed.connect(func() -> void: OS.shell_open(Tolgee.interface().project_uri() + "/manage/edit"))
    Tolgee.interface().validated.connect(self._on_client_validated)
    ProjectSettings.settings_changed.connect(self._update_ui)

func _update_ui() -> void:
    self._enable_namespaces_button.visible = !Tolgee.interface().use_namespaces()
    if Tolgee.interface().is_linked():
        self._project_name.text = Tolgee.interface().project_name()
        self._project_name.uri = Tolgee.interface().project_uri()
        self._project_name.underline = LinkButton.UNDERLINE_MODE_ALWAYS
    else:
        self._project_name.text = "-"
        self._project_name.uri = ""
        self._project_name.underline = LinkButton.UNDERLINE_MODE_NEVER
    var cfg_warnings: PackedStringArray = Tolgee.interface().config_warnings()
    if !Tolgee.interface().is_linked():
        cfg_warnings.append("Not linked to a project. Verify host and API key.")
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

func _on_check_status_button_pressed() -> void:
    self._status_checking.visible = true
    Tolgee.interface().validate()
