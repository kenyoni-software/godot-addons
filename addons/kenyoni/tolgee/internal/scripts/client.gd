extends Node
## callback completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, body_json: Variant)

const Request := preload("res://addons/kenyoni/tolgee/internal/scripts/request.gd")
const HTTPMultiPartFormData := preload("res://addons/kenyoni/tolgee/internal/scripts/http_multipart_form_data.gd")

const API_KEY_HEADER_KEY: String = "x-api-key"

var host: String = "":
    set = set_host
var api_key: String = ""

func set_host(value: String) -> void:
    host = value.rstrip("/")

func _init(host_: String, api_key_: String) -> void:
    self.host = host_
    self.api_key = api_key_

## https://docs.tolgee.io/api/get-current-permissions
func get_api_keys_current_permissions(completed: Variant = null) -> Error:
    return self._new_request(completed).request(self.host + "/v2/api-keys/current-permissions", self._default_headers(), HTTPClient.METHOD_GET)

class GetProjectsOptions:
    extends RefCounted

    var base_language_id: int = -1
    var default_namespace_id: int = -1
    var description: String = ""
    var slug: String = ""

## https://docs.tolgee.io/api/get-4
func get_project(project_id: int, completed: Variant = null) -> Error:
    return self._new_request(completed).request(self.host + "/v2/projects/" + str(project_id), self._default_headers(), HTTPClient.METHOD_GET)

## https://docs.tolgee.io/api/edit-project
func update_project(project_id: int, icu_placeholders: bool, project_name: String, use_namespaces: bool, options: GetProjectsOptions = null, completed: Variant = null) -> Error:
    var body: Dictionary = {
        "icuPlaceholders": icu_placeholders,
        "name": project_name,
        "useNamespaces": use_namespaces,
    }
    if options != null:
        if options.base_language_id != -1:
            body["baseLanguageId"] = options.base_language_id
        if options.default_namespace_id != -1:
            body["defaultNamespaceId"] = options.default_namespace_id
        if options.description != "":
            body["description"] = options.description
        if options.slug != "":
            body["slug"] = options.slug
    return self._new_request(completed).request(self.host + "/v2/projects/" + str(project_id), self._default_headers(), HTTPClient.METHOD_PUT, JSON.stringify(body))

class GetAllLanguagesOptions:
    extends RefCounted

    var page: int = 0
    var size: int = 0
    var sort: PackedStringArray = PackedStringArray()
    var filter_id: Array[int] = []
    var filter_not_id: Array[int] = []

## https://docs.tolgee.io/api/get-all-7
func get_all_languages(project_id: int, options: GetAllLanguagesOptions = null, completed: Variant = null) -> Error:
    var url: String = self.host + "/v2/projects/" + str(project_id) + "/languages"
    var query: PackedStringArray = []
    if options != null:
        if options.page != 0:
            query.append("page=" + str(options.page))
        if options.size != 0:
            query.append("size=" + str(options.size))
        if options.sort.size() > 0:
            query.append("sort=" + ",".join(options.sort))
        if options.filter_id.size() > 0:
            query.append("filterId=" + ",".join(options.filter_id))
        if options.filter_not_id.size() > 0:
            query.append("filterNotId=" + ",".join(options.filter_not_id))
    if query.size() > 0:
        url += "?" + "&".join(query)
    return self._new_request(completed).request(url, self._default_headers(), HTTPClient.METHOD_GET)

## https://docs.tolgee.io/api/create-language
func create_language(project_id: int, name: String, original_name: String, tag: String, flag_emoji: String = "", completed: Variant = null) -> Error:
    var body: Dictionary = {
        "name": name,
        "originalName": original_name,
        "tag": tag,
    }
    if flag_emoji != "":
        body["flagEmoji"] = flag_emoji
    return self._new_request(completed).request(self.host + "/v2/projects/" + str(project_id) + "/languages", self._default_headers(), HTTPClient.METHOD_POST, JSON.stringify(body))

## https://docs.tolgee.io/api/delete-language-2
func delete_language(project_id: int, language_id: int, completed: Variant = null) -> Error:
    return self._new_request(completed).request(self.host + "/v2/projects/" + str(project_id) + "/languages/" + str(language_id), self._default_headers(), HTTPClient.METHOD_DELETE)

class PostSingleStepImportFile:
    extends RefCounted

    var filename: String = ""
    var data: PackedByteArray = PackedByteArray()

    func _init(filename_: String, data_: PackedByteArray) -> void:
        self.filename = filename_
        self.data = data_

class PostSingleStepImportFileMapping:
    extends RefCounted

    var filename: String = ""
    var format: String = ""
    var language_tag: String = ""
    var language_tags_to_import: PackedStringArray = PackedStringArray()
    var namespace_str: String = ""

    func _init(filename_: String) -> void:
        self.filename = filename_

class PostSingleStepImportParams:
    extends RefCounted

    var files: Array[PostSingleStepImportFile] = []

    var convert_placeholders_to_icu: bool = false
    var create_new_keys: bool = false
    var file_mappings: Array[PostSingleStepImportFileMapping] = []
    var force_mode: String = ""
    var override_key_descriptions: bool = false
    var remove_other_keys: bool = false
    var tag_new_keys: PackedStringArray = PackedStringArray()

## https://docs.tolgee.io/api/do-import
func single_step_import(project_id: int, params: PostSingleStepImportParams, completed: Variant = null) -> Error:
    var multipart: HTTPMultiPartFormData = HTTPMultiPartFormData.new()

    for file: PostSingleStepImportFile in params.files:
        var part: HTTPMultiPartFormData.Part = HTTPMultiPartFormData.Part.new()
        part.name = "files"
        part.filename = file.filename
        part.data = file.data
        multipart.add(part)

    var params_part: HTTPMultiPartFormData.Part = HTTPMultiPartFormData.Part.new()
    params_part.name = "params"
    var data: Dictionary = {
        "convertPlaceholdersToIcu": params.convert_placeholders_to_icu,
        "createNewKeys": params.create_new_keys,
        "fileMappings": [],
        "forceMode": params.force_mode,
        "overrideKeyDescriptions": params.override_key_descriptions,
        "removeOtherKeys": params.remove_other_keys,
        "tagNewKeys": params.tag_new_keys,
    }
    var file_mappings: Array = []
    for file_mapping: PostSingleStepImportFileMapping in params.file_mappings:
        var mapping: Dictionary = {
            "fileName": file_mapping.filename,
        }
        if file_mapping.format != "":
            mapping["format"] = file_mapping.format
        if file_mapping.language_tag != "":
            mapping["languageTag"] = file_mapping.language_tag
        if file_mapping.language_tags_to_import.size() > 0:
            mapping["languageTagsToImport"] = file_mapping.language_tags_to_import
        if file_mapping.namespace_str != "":
            mapping["namespace"] = file_mapping.namespace_str
        file_mappings.append(mapping)
    data["fileMappings"] = file_mappings
    params_part.data = JSON.stringify(data)
    multipart.add(params_part)
    multipart.generate()

    var req: Request = self._new_request(completed)
    var headers: PackedStringArray = self._default_headers()
    headers.append("Content-Type: " + multipart.content_type_header())

    return req.request_raw(self.host + "/v2/projects/" + str(project_id) + "/single-step-import", headers, HTTPClient.METHOD_POST, multipart.body())

class ExportDataOptions:
    extends RefCounted

    var file_structure_template: String = ""
    var filter_namespace: Array[String] = []
    var filter_state: Array[String] = []
    var languages: Array[String] = []
    var message_format: String = ""

func export_data(project_id: int, format: String, supportArrays: bool, zip: bool, options: ExportDataOptions = null, download_file: String = "", completed: Variant = null) -> Error:
    var body: Dictionary = {
        "format": format,
        "supportArrays": supportArrays,
        "zip": zip,
    }
    if options != null:
        if options.file_structure_template != "":
            body["fileStructureTemplate"] = options.file_structure_template
        if options.filter_namespace.size() > 0:
            body["filterNamespace"] = options.filter_namespace
        if options.filter_state.size() > 0:
            body["filterState"] = options.filter_state
        if options.languages.size() > 0:
            body["languages"] = options.languages
        if options.message_format != "":
            body["messageFormat"] = options.message_format
    var req: Request = self._new_request(completed, false)
    if download_file != "":
        req.download_file = download_file
    return req.request(self.host + "/v2/projects/" + str(project_id) + "/export", self._default_headers(), HTTPClient.METHOD_POST, JSON.stringify(body))

func _default_headers() -> PackedStringArray:
    return [
        "User-Agent: Kenyoni Tolgee Godot Integration",
        API_KEY_HEADER_KEY + ": " + self.api_key,
    ]

func _new_request(completed: Variant = null, decode_json: bool = true) -> Request:
    var req: Request = Request.new(decode_json)
    self.add_child(req, false, INTERNAL_MODE_BACK)
    if completed != null:
        req.completed.connect(completed as Callable)
    return req
