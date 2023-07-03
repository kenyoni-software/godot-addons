extends MarginContainer

const Component := preload("res://addons/licenses/component.gd")

@export_node_path("Label") var _name_path; @onready var _name: Label = self.get_node(_name_path)
@export_node_path("Label") var _version_path; @onready var _version: Label = self.get_node(_version_path)
@export_node_path("RichTextLabel") var _description_path; @onready var _description: RichTextLabel = self.get_node(_description_path)
@export_node_path("RichTextLabel") var _contact_path; @onready var _contact: RichTextLabel = self.get_node(_contact_path)
@export_node_path("RichTextLabel") var _web_path; @onready var _web: RichTextLabel = self.get_node(_web_path)
@export_node_path("RichTextLabel") var _license_path; @onready var _license: RichTextLabel = self.get_node(_license_path)
@export_node_path("RichTextLabel") var _license_text_path; @onready var _license_text: RichTextLabel = self.get_node(_license_text_path)

func set_component(component: Component) -> void:
    self._name.text = component.name
    self._version.text = component.version
    self._description.text = component.description
    self._contact.text = component.contact
    self._web.text = component.web
    self._license.text = ""
    self._license_text.text = ""
    for idx in range(len(component.licenses)):
        var license: Component.License = component.licenses[idx]
        if idx > 0:
            self._license.text = self._license.text + " & "
            self._license_text.text = self._license_text.text + "\n=========================\n"
        self._license.text = self._license.text + license.name
        self._license_text.text = self._license_text.text + license.get_license_text()
