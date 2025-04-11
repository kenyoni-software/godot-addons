@tool
class_name _Tolgee
extends Node
## Interface for Tolgee

const Flow := preload("res://addons/kenyoni/tolgee/internal/scripts/flow/flow.gd")
const ValidateFlow := preload("res://addons/kenyoni/tolgee/internal/scripts/flow/validate.gd")
const UploadTranslationsFlow := preload("res://addons/kenyoni/tolgee/internal/scripts/flow/upload_translations.gd")
const DownloadTranslationsFlow := preload("res://addons/kenyoni/tolgee/internal/scripts/flow/download_translations.gd")

const Client := preload("res://addons/kenyoni/tolgee/internal/scripts/client.gd")

const CFG_KEY_API_KEY: String = "plugins/tolgee/api_key"
const CFG_KEY_HOST: String = "plugins/tolgee/host"
const CFG_KEY_UPLOAD_ADD_NEW: String = "plugins/tolgee/upload/add_new"
const CFG_KEY_UPLOAD_REMOVE_MISSING: String = "plugins/tolgee/upload/remove_missing"
const CFG_KEY_UPLOAD_OVERRIDE_EXISTING: String = "plugins/tolgee/upload/override_existing"
const CFG_KEY_FILES: String = "plugins/tolgee/files"

const LOCALIZATION_NONE: String = "none"
const LOCALIZATION_CSV: String = "csv"
const LOCALIZATION_GETTEXT: String = "gettext"

# https://docs.tolgee.io/platform/formats/message_placeholder_format
const PLACEHOLDER_ICU: String = "icu"
const PLACEHOLDER_PHP: String = "php"
const PLACEHOLDERS: Array[String] = [PLACEHOLDER_ICU, PLACEHOLDER_PHP]

## emitted right before validation
signal pre_validation()
## send after the API key and project was validated, to check if the project is linked use is_linked()
## if the host or API key was changed this will always be emitted
signal validated(err_msg: String)

var _client: Client = Client.new("", "")

## API response containing all the project details
var _project: Dictionary = {}
var _api_key_scopes: PackedStringArray = []

## singleton interface
static var _interface: _Tolgee = null

func _init() -> void:
    self._client.host = ProjectSettings.get_setting(CFG_KEY_HOST, "")
    self._client.api_key = ProjectSettings.get_setting(CFG_KEY_API_KEY, "")
    self.add_child(self._client, false, INTERNAL_MODE_BACK)

    ProjectSettings.settings_changed.connect(self._on_settings_changed)

func host() -> String:
    return self._client.host

func is_linked() -> bool:
    return !self._project.is_empty()

func is_operating() -> bool:
    return self.is_linked() && self.config_warnings().size() == 0

func project_name() -> String:
    return self._project.get("name", "")

func project_id() -> int:
    return self._project.get("id", -1)

func project_uri() -> String:
    return self._client.host + "/projects/" + str(self.project_id())

func use_namespaces() -> bool:
    return self._project.get("useNamespaces", false)

func has_api_scope(scope: String) -> bool:
    return self._api_key_scopes.has(scope)

## Array[Dictionary]
func files() -> Array[Dictionary]:
    var files: Array[Dictionary] = []
    files.assign(ProjectSettings.get_setting(CFG_KEY_FILES, []))
    return files

func config_warnings() -> PackedStringArray:
    var warnings: PackedStringArray = []
    if self.host() == "":
        warnings.append("Host is not set.")
    if self._client.api_key == "":
        warnings.append("API Key is not set.")

    if self.is_linked():
        if !self.use_namespaces():
            warnings.append("Project requires namespaces. Please enable namespaces in the web view.")
        var missing_scopes: Array = []
        for scope: String in ["keys.create", "keys.delete", "keys.edit", "keys.view", "languages.edit", "translations.edit", "translations.state-edit", "translations.view"]:
            if !self._api_key_scopes.has(scope):
                missing_scopes.append(scope)
        if missing_scopes.size() > 0:
            warnings.append("API Key is missing the following scopes: " + ", ".join(missing_scopes))

    var files: Array[Dictionary] = self.files()
    for idx: int in range(files.size()):
        var tr_cfg: Dictionary = files[idx]
        if !tr_cfg.has("input_path"):
            warnings.append("%d: Input path is not set." % idx)
        elif !FileAccess.file_exists(tr_cfg["input_path"]):
            warnings.append("%d: Input path does not exist." % idx)
        if !tr_cfg.has("output_path"):
            warnings.append("%d: Output path is not set." % idx)
        elif tr_cfg.has("input_path"):
            match tr_cfg["input_path"].get_extension():
                "csv":
                    if tr_cfg["output_path"].get_extension() != "csv":
                        warnings.append("%d: Output path is not a CSV file." % idx)
                "pot":
                    if FileAccess.file_exists(tr_cfg["output_path"]):
                        warnings.append("%d: Output path is not a directory." % idx)
        if !tr_cfg.has("placeholder"):
            warnings.append("%d: Placeholder is not set." % idx)
        elif tr_cfg["placeholder"] not in PLACEHOLDERS:
            warnings.append("%d: Placeholder is invalid." % idx)

    return warnings

## callback: Callable[String]
func validate() -> void:
    if self._client.host == "" || self._client.api_key == "":
        self.validated.emit("Host or API Key is not set.")
        return

    ValidateFlow.new(self).run()

## returns true if added
func add_translation_file(tr_cfg: Dictionary) -> bool:
    if !tr_cfg.has("input_path"):
        push_error("[Tolgee] Missing required field 'input_path'.")
        return false
    elif !tr_cfg.has("output_path"):
        push_error("[Tolgee] Missing required field 'output_path'.")
        return false
    elif !tr_cfg.has("placeholder"):
        push_error("[Tolgee] Missing required field 'placeholder'.")
        return false

    var files: Array = self.files()
    var idx: int = files.find_custom(func(item: Dictionary) -> bool:
        return item.get("input_path") == tr_cfg.get("input_path")
    )
    if idx != -1:
        files[idx] = tr_cfg
    else:
        files.append(tr_cfg)
    ProjectSettings.set_setting(CFG_KEY_FILES, files)
    ProjectSettings.save()
    return true

func remove_translation_file(input_path: String) -> void:
    var files: Array = self.files()
    var idx: int = files.find_custom(func(item: Dictionary) -> bool:
        return item.get("input_path") == input_path
    )
    if idx != -1:
        files.remove_at(idx)
        ProjectSettings.set_setting(CFG_KEY_FILES, files)
        ProjectSettings.save()

func download_translations() -> void:
    pass

func upload_translations() -> void:
    UploadTranslationsFlow.new(self).run()

func _clear_project() -> void:
    self._project = {}
    self._api_key_scopes = []

func _on_settings_changed() -> void:
    var host: String = ProjectSettings.get_setting(CFG_KEY_HOST, "")
    var api_key: String = ProjectSettings.get_setting(CFG_KEY_API_KEY, "")
    if self._client.host == host && self._client.api_key == api_key:
        return
    self._clear_project()
    self._client.host = host
    self._client.api_key = api_key
    self.validate()

func _on_validated(err_msg: String) -> void:
    if err_msg != "":
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to initialize.", EditorToaster.SEVERITY_ERROR, err_msg)

static func init():
    _interface = _Tolgee.new()

static func interface() -> _Tolgee:
    return _interface

static func placeholder_to_message_format(placeholder: String) -> String:
    match placeholder:
        PLACEHOLDER_ICU:
            return "ICU"
        PLACEHOLDER_PHP:
            return "PHP_SPRINTF"
    return "ICU"

## if uid is not an UID it will return the string without changes
static func uid_to_path(uid: String) -> String:
    if uid.begins_with("uid://"):
        return ResourceUID.get_id_path(ResourceUID.text_to_id(uid))
    return uid
