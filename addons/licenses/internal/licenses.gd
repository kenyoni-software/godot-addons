@tool
extends MarginContainer

const Licenses := preload("../licenses.gd")
const ComponentsTree := preload("components_tree.gd")

@export_node_path("Tree") var _components_tree_path; @onready var _components_tree: ComponentsTree = self.get_node(self._components_tree_path)
@export var _license_file_edit: LineEdit = null
@export var _license_file_load_button: Button = null
@export var _set_license_filepath_button: Button = null

func _ready() -> void:
    self._license_file_load_button.icon = self.get_theme_icon("Load", "EditorIcons")
    self._license_file_load_button.pressed.connect(self._on_data_file_load_button_clicked)
    self._set_license_filepath_button.icon = self.get_theme_icon("ImportCheck", "EditorIcons")
    self._set_license_filepath_button.pressed.connect(self._on_set_license_filepath_clicked)
    self._license_file_edit.text_submitted.connect(self._on_data_file_edit_changed)
    self._license_file_edit.text = Licenses.get_license_data_filepath()
    self.reload()

func reload() -> void:
    self._update_set_license_filepath_button()
    var res: Licenses.LoadResult = Licenses.load(self._license_file_edit.text)
    if res.err_msg == "":
        self._license_file_edit.right_icon = null
        self._license_file_edit.tooltip_text = ""
    else:
        self._license_file_edit.right_icon = self.get_theme_icon("NodeWarning", "EditorIcons")
        self._license_file_edit.tooltip_text = res.err_msg
    res.components.sort_custom(Licenses.compare_components_ascending)
    self._components_tree.set_components(res.components)

func _update_set_license_filepath_button() -> void:
    if Licenses.get_license_data_filepath() == self._license_file_edit.text:
        self._set_license_filepath_button.icon = self.get_theme_icon("ImportCheck", "EditorIcons")
        self._set_license_filepath_button.tooltip_text = "Selected file is set as the project license file."
        self._set_license_filepath_button.disabled = true
    else:
        self._set_license_filepath_button.icon = self.get_theme_icon("ImportFail", "EditorIcons")
        self._set_license_filepath_button.tooltip_text = "Set the current file as project license file."
        self._set_license_filepath_button.disabled = false

func _on_data_file_load_button_clicked() -> void:
    var dialog: FileDialog = FileDialog.new()
    dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
    dialog.current_path = self._license_file_edit.text
    self.add_child(dialog)
    dialog.popup_centered_ratio(0.4)
    dialog.close_requested.connect(dialog.queue_free)
    dialog.file_selected.connect(self._on_data_file_selected)

func _on_data_file_edit_changed(new_text: String) -> void:
    self._on_data_file_selected(new_text)

func _on_data_file_selected(path: String) -> void:
    self._license_file_edit.text = path
    self.reload()

func _on_set_license_filepath_clicked() -> void:
    Licenses.set_license_data_filepath(self._license_file_edit.text)
    self._update_set_license_filepath_button()

func _on_components_changed() -> void:
    Licenses.save(self._components_tree.get_components(), self._license_file_edit.text)
