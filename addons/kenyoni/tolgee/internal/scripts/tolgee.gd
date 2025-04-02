@tool
class_name _Tolgee
extends Node
## Interface for Tolgee

const ValidateFlow := preload("res://addons/kenyoni/tolgee/internal/scripts/flow/validate.gd")
const UpdateLanguagesFlow := preload("res://addons/kenyoni/tolgee/internal/scripts/flow/update_languages.gd")
const PushCsvFlow := preload("res://addons/kenyoni/tolgee/internal/scripts/flow/push_csv.gd")

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

    var flow: ValidateFlow = ValidateFlow.new(self, callback as Callable)
    flow.completed.connect(func(_err: Error) -> void: flow.finish())
    flow.run()

func push_translation_keys() -> void:
    match self.localization():
        LOCALIZATION_NONE:
            EditorInterface.get_editor_toaster().push_toast("[Tolgee] No localization is selected.", EditorToaster.SEVERITY_WARNING)
        LOCALIZATION_CSV:
            self._push_csv_translation_keys()
        LOCALIZATION_GETTEXT:
            EditorInterface.get_editor_toaster().push_toast("[Tolgee] gettext localization is not supported yet.", EditorToaster.SEVERITY_WARNING)

func _use_namespaces() -> bool:
    return self._project.get("useNamespaces", false)

func _push_csv_translation_keys() -> void:
    var languages: Array[String] = []
    var file_data_arr: Array[PackedByteArray] = []
    var files: Array[String] = []
    files.assign(ProjectSettings.get_setting(CFG_KEY_CSV_FILES, []))
    for file_path: String in files:
        var file_data: PackedByteArray = FileAccess.get_file_as_bytes(file_path)
        if file_data.size() == 0 && FileAccess.get_open_error() != OK:
            var err_msg: String = "Failed to open file: '%s' - %s" % [file_path, error_string(FileAccess.get_open_error())]
            push_error("[Tolgee] " + err_msg)
            EditorInterface.get_editor_toaster().push_toast("[Tolgee] Could not push translation keys.", EditorToaster.SEVERITY_ERROR, err_msg)
            return
        file_data_arr.append(file_data)
        # get languages
        var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
        if file == null:
            var err_msg: String = "Failed to open file: '%s' - %s" % [file_path, error_string(FileAccess.get_open_error())]
            push_error("[Tolgee] " + err_msg)
            EditorInterface.get_editor_toaster().push_toast("[Tolgee] Could not push translation keys.", EditorToaster.SEVERITY_ERROR, err_msg)
            return
        var cur_languages: PackedStringArray = file.get_csv_line()
        file.close()
        cur_languages.remove_at(0)
        for cur_lang: String in cur_languages:
            if !languages.has(cur_lang):
                languages.append(cur_lang)

    var flow_lang: UpdateLanguagesFlow = UpdateLanguagesFlow.new(self, languages)
    flow_lang.completed.connect(
        func(err: Error) -> void:
            if err != OK:
                flow_lang.finish()
                return
            var flow: PushCsvFlow = PushCsvFlow.new(self, file_data_arr, files, self.placeholder())
            flow.completed.connect(func(_err2: Error) -> void: flow_lang.finish(); flow.finish())
            flow.run()
    )
    flow_lang.run()

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
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to initialize Tolgee: " + err_msg, EditorToaster.SEVERITY_ERROR)

static func init():
    _interface = _Tolgee.new()

static func interface() -> _Tolgee:
    return _interface
