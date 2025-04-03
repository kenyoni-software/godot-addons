@tool
class_name _Tolgee
extends Node
## Interface for Tolgee

const ValidateFlow := preload("res://addons/kenyoni/tolgee/internal/scripts/flow/validate.gd")
const UploadCsvFlow := preload("res://addons/kenyoni/tolgee/internal/scripts/flow/upload_csv.gd")
const DownloadCsvFlow := preload("res://addons/kenyoni/tolgee/internal/scripts/flow/download_csv.gd")

const Client := preload("res://addons/kenyoni/tolgee/internal/scripts/client.gd")

const CFG_KEY_API_KEY: String = "plugins/tolgee/api_key"
const CFG_KEY_HOST: String = "plugins/tolgee/host"
const CFG_KEY_LIVE_SYNC: String = "plugins/tolgee/live_sync"
const CFG_KEY_LOCALIZATION: String = "plugins/tolgee/localization"
const CFG_KEY_PO_OUT_DIRECTORY: String = "plugins/tolgee/gettext/po_out_directory"
const CFG_KEY_POT_FILES: String = "plugins/tolgee/gettext/pot_files"
const CFG_KEY_CSV_FILES: String = "plugins/tolgee/csv/files"
const CFG_KEY_PLACEHOLDER: String = "plugins/tolgee/placeholder"

const LOCALIZATION_NONE: String = "none"
const LOCALIZATION_CSV: String = "csv"
const LOCALIZATION_GETTEXT: String = "gettext"

# https://docs.tolgee.io/platform/formats/message_placeholder_format
const PLACEHOLDER_ICU: String = "icu"
const PLACEHOLDER_PHP: String = "php"
const PLACEHOLDER_JAVA: String = "java"

signal linked(is_linked: bool)

var _client: Client = Client.new("", "")

# API response containing all the project details
var _project: Dictionary = {}
var _api_key_scopes: PackedStringArray = []

# singleton interface
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

func localization() -> String:
    return ProjectSettings.get_setting(CFG_KEY_LOCALIZATION, LOCALIZATION_NONE)

func placeholder() -> String:
    return ProjectSettings.get_setting(CFG_KEY_PLACEHOLDER, PLACEHOLDER_ICU)

func config_warnings() -> PackedStringArray:
    var warnings: PackedStringArray = []
    if self.host() == "":
        warnings.append("Host is not set.")
    if self._client.api_key == "":
        warnings.append("API Key is not set.")

    if self.is_linked():
        if !self._use_namespaces() && !self._api_key_scopes.has("project.edit"):
            warnings.append("Project requires namespaces. Please enable namespaces manually or grant 'project.edit' to the API key.")
        var missing_scopes: Array = []
        for scope: String in ["keys.create", "keys.delete", "keys.edit", "keys.view", "languages.edit", "translations.edit", "translations.state-edit", "translations.view"]:
            if !self._api_key_scopes.has(scope):
                missing_scopes.append(scope)
        if missing_scopes.size() > 0:
            warnings.append("API Key is missing the following scopes: " + ", ".join(missing_scopes))

    match self.localization():
        LOCALIZATION_NONE:
            warnings.append("Workflow is not set.")
        LOCALIZATION_CSV:
            if ProjectSettings.get_setting(CFG_KEY_CSV_FILES, []).size() == 0:
                warnings.append("CSV files are not set.")
        LOCALIZATION_GETTEXT:
            if ProjectSettings.get_setting(CFG_KEY_POT_FILES, []) == []:
                warnings.append("POT files are not set.")
            if ProjectSettings.get_setting(CFG_KEY_PO_OUT_DIRECTORY, "") == "":
                warnings.append("PO Output Directory is not set.")
    return warnings

## callback: Callable[String]
func validate(callback: Variant = null) -> void:
    if self._client.host == "" || self._client.api_key == "":
        return

    if callback == null:
        callback = self._on_validated

    ValidateFlow.new(self, callback as Callable).run()

func upload_translations() -> void:
    match self.localization():
        LOCALIZATION_NONE:
            EditorInterface.get_editor_toaster().push_toast("[Tolgee] No localization is selected.", EditorToaster.SEVERITY_WARNING)
        LOCALIZATION_CSV:
            UploadCsvFlow.new(self).run()
        LOCALIZATION_GETTEXT:
            EditorInterface.get_editor_toaster().push_toast("[Tolgee] gettext localization is not supported yet.", EditorToaster.SEVERITY_WARNING)

func download_translations() -> void:
    match self.localization():
        LOCALIZATION_NONE:
            EditorInterface.get_editor_toaster().push_toast("[Tolgee] No localization is selected.", EditorToaster.SEVERITY_WARNING)
        LOCALIZATION_CSV:
            DownloadCsvFlow.new(self).run()
        LOCALIZATION_GETTEXT:
            EditorInterface.get_editor_toaster().push_toast("[Tolgee] gettext localization is not supported yet.", EditorToaster.SEVERITY_WARNING)

func _use_namespaces() -> bool:
    return self._project.get("useNamespaces", false)

func _clear_project() -> void:
    self._project = {}
    self._api_key_scopes = []
    self.linked.emit(false)

func _on_settings_changed() -> void:
    var host: String = ProjectSettings.get_setting(CFG_KEY_HOST, "")
    var api_key: String = ProjectSettings.get_setting(CFG_KEY_API_KEY, "")
    if self._client.host == host && self._client.api_key == api_key:
        return
    self._client.host = host
    self._client.api_key = api_key
    self._clear_project()
    self.validate()

func _on_validated(err_msg: String) -> void:
    if err_msg != "":
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to initialize: " + err_msg, EditorToaster.SEVERITY_ERROR)

static func init():
    _interface = _Tolgee.new()

static func interface() -> _Tolgee:
    return _interface

static func placeholder_to_message_format(placeholder: String) -> String:
    match placeholder:
        PLACEHOLDER_ICU:
            return "ICU"
        PLACEHOLDER_JAVA:
            return "JAVA_STRING_FORMAT"
        PLACEHOLDER_PHP:
            return "PHP_SPRINTF"
    return "ICU"

## if uid is not an UID it will return the string without changes
static func uid_to_path(uid: String) -> String:
    if uid.begins_with("uid://"):
        return ResourceUID.get_id_path(ResourceUID.text_to_id(uid))
    return uid
