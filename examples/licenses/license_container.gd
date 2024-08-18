extends MarginContainer

const Component := preload("res://addons/licenses/component.gd")

@export var _name: Label
@export var _version: Label
@export var _description: RichTextLabel
@export var _contact: RichTextLabel
@export var _web: RichTextLabel
@export var _license: RichTextLabel
@export var _license_text: RichTextLabel

func set_component(component: Component) -> void:
    self._name.text = component.name
    self._version.text = component.version
    self._description.text = component.description
    self._contact.text = component.contact
    self._web.text = component.web
    self._license.text = ""
    self._license_text.text = ""
    for idx: int in range(len(component.licenses)):
        var license: Component.License = component.licenses[idx]
        if idx > 0:
            self._license.text = self._license.text + " & "
            self._license_text.text = self._license_text.text + "\n=========================\n"
        self._license.text = self._license.text + license.name
        self._license_text.text = self._license_text.text + license.get_license_text()
