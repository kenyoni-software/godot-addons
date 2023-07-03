@tool
extends MarginContainer

const Licenses := preload("../licenses.gd")
const ComponentsTree := preload("components_tree.gd")

@export_node_path("Tree") var _components_tree_path; @onready var _components_tree: ComponentsTree = self.get_node(self._components_tree_path)
@export_node_path("LineEdit") var _license_file_edit_path; @onready var _license_file_edit: LineEdit = self.get_node(self._license_file_edit_path)
@export_node_path("Button") var _license_file_load_button_path; @onready var _license_file_load_button: Button = self.get_node(self._license_file_load_button_path)

func _ready() -> void:
    self._license_file_load_button.icon = self.get_theme_icon("Load", "EditorIcons")
    self._license_file_load_button.pressed.connect(self._on_data_file_load_button_clicked)
    self._license_file_edit.text_submitted.connect(self._on_data_file_edit_changed)
    self._license_file_edit.text = Licenses.get_license_data_filepath()
    self.reload()

func reload() -> void:
    var res: Licenses.LoadResult = Licenses.load(Licenses.get_license_data_filepath())
    if res.err_msg == "":
        self._license_file_edit.right_icon = null
        self._license_file_edit.tooltip_text = ""
    else:
        self._license_file_edit.right_icon = self.get_theme_icon("NodeWarning", "EditorIcons")
        self._license_file_edit.tooltip_text = res.err_msg
    self._components_tree.licenses = res.components
    self._components_tree.licenses.sort_custom(Licenses.new().compare_components_ascending)
    self._components_tree.reload()

func _on_data_file_load_button_clicked() -> void:
    var dialog: FileDialog = FileDialog.new()
    dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
    dialog.current_path = Licenses.get_license_data_filepath()
    self.add_child(dialog)
    dialog.popup_centered_ratio(0.4)
    dialog.close_requested.connect(dialog.queue_free)
    dialog.file_selected.connect(self._on_data_file_selected)

func _on_data_file_edit_changed(new_text: String) -> void:
    self._on_data_file_selected(new_text)

func _on_data_file_selected(path: String) -> void:
    Licenses.set_license_data_file(path)
    self._license_file_edit.text = path
    self.reload()
