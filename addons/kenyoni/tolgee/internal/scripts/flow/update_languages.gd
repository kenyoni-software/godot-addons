extends "res://addons/kenyoni/tolgee/internal/scripts/flow/flow.gd"

const Client := preload("res://addons/kenyoni/tolgee/internal/scripts/client.gd")

var _languages: Array[String] = []
## id to tag
var _missing_languages: Array[String] = []
## id to tag
var _delete_languages: Dictionary[String, int] = {}

func _init(tolgee: Tolgee, languages: Array[String]) -> void:
    super._init(tolgee)
    self._languages = languages

## OVERRIDE
func run() -> void:
    var lang_options: Client.GetAllLanguagesOptions = Client.GetAllLanguagesOptions.new()
    lang_options.page = 0
    lang_options.size = 1000
    self._tolgee._client.get_all_languages(self._tolgee.project_id(), lang_options, self._on_create_languages_1)

static func locale_to_bcp_47(locale: String) -> String:
    var parts: Array[String] = locale.split("_", true, 3)
    var bcp_47: Array[String] = []
    if parts.size() > 0:
        bcp_47.append(parts[0].to_lower())
    if parts.size() > 1:
        bcp_47.append(parts[1].capitalize())
    if parts.size() > 2:
        bcp_47.append(parts[2].to_upper())
    if parts.size() > 3:
        bcp_47.append(parts[3].replace("_", "-"))
    return "-".join(bcp_47)

func _update_languages() -> void:
    for lang: String in self._missing_languages:
        var std_locale: String = TranslationServer.standardize_locale(lang)
        self._tolgee._client.create_language(self._tolgee.project_id(), TranslationServer.get_locale_name(std_locale), TranslationServer.get_language_name(std_locale), lang, "", self._on_language_created.bind(lang))
        return
    for lang: String in self._delete_languages:
        self._tolgee._client.delete_language(self._tolgee.project_id(), self._delete_languages[lang], self._on_language_removed.bind(lang))
        return
    self.completed.emit(OK)

func _on_create_languages_1(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, body_json: Variant) -> void:
    if result != OK:
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Could not get languages: " + str(result), EditorToaster.SEVERITY_ERROR)
        self.completed.emit(FAILED)
        return
    if response_code != HTTPClient.RESPONSE_OK:
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Could not get languages: " + str(response_code) + " | " + body.get_string_from_utf8(), EditorToaster.SEVERITY_ERROR)
        self.completed.emit(FAILED)
        return

    self._delete_languages.clear()
    self._missing_languages.clear()
    var cur_languages: Array = body_json.get("_embedded", {}).get("languages", [])
    for lang: Dictionary in cur_languages:
        var tag: String = lang.get("tag", "")
        if tag != "" && lang.has("id") && !self._languages.has(tag):
            self._delete_languages[tag] = int(lang.get("id", 0))
    for lang: String in self._languages:
        if cur_languages.find_custom(func (val: Dictionary) -> bool: return val.get("tag", "") == lang) == -1:
            self._missing_languages.append(lang)

    self._update_languages()

func _on_language_created(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, body_json: Variant, language: String) -> void:
    if result != OK:
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to create language: " + str(result) + " | " + language, EditorToaster.SEVERITY_ERROR)
        self.completed.emit(FAILED)
        return
    if response_code != HTTPClient.RESPONSE_OK:
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to update languages: " + str(response_code) + " | " + body.get_string_from_utf8(), EditorToaster.SEVERITY_ERROR)
        self.completed.emit(FAILED)
        return
    self._missing_languages.remove_at(self._missing_languages.find(language))
    self._update_languages()

func _on_language_removed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, body_json: Variant, language: String):
    if result != OK:
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to remove language: " + str(result) + " | " + language, EditorToaster.SEVERITY_ERROR)
        self.completed.emit(FAILED)
        return
    if response_code != HTTPClient.RESPONSE_OK:
        EditorInterface.get_editor_toaster().push_toast("[Tolgee] Failed to update languages: " + str(response_code) + " | " + body.get_string_from_utf8(), EditorToaster.SEVERITY_ERROR)
        self.completed.emit(FAILED)
        return
    self._delete_languages.erase(language)
    self._update_languages()
