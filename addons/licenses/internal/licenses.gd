@tool
extends MarginContainer

const Licenses := preload("res://addons/licenses/licenses.gd")
const Component := preload("res://addons/licenses/component.gd")
const ComponentsTree := preload("res://addons/licenses/internal/components_tree.gd")
const ComponentDetailTree := preload("res://addons/licenses/internal/component_detail_tree.gd")
const Toolbar := preload("res://addons/licenses/internal/toolbar.gd")
const LicensesInterface := preload("res://addons/licenses/internal/plugin/licenses_interface.gd")
# handler
const BaseHandler := preload("res://addons/licenses/internal/handler/base.gd")
const ObjectHandler := preload("res://addons/licenses/internal/handler/object.gd")
const ArrayHandler := preload("res://addons/licenses/internal/handler/array.gd")
const StringHandler := preload("res://addons/licenses/internal/handler/string.gd")
const StringFileHandler := preload("res://addons/licenses/internal/handler/string_file.gd")
const StringMultiLineHandler := preload("res://addons/licenses/internal/handler/string_multiline.gd")

@export var _components_tree: ComponentsTree
@export var _component_detail_tree: ComponentDetailTree
@export var _toolbar: Toolbar
@export var _license_file_edit: LineEdit = null
@export var _license_file_load_button: Button = null
@export var _set_license_filepath_button: Button = null

var _li: LicensesInterface
var _current_indentation: String = ""

func _ready() -> void:
    self._license_file_load_button.icon = self.get_theme_icon(&"FileBrowse", &"EditorIcons")
    self._license_file_load_button.pressed.connect(self._on_data_file_load_button_clicked)
    self._license_file_load_button.tooltip_text = "Select a license file to load."
    self._set_license_filepath_button.icon = self.get_theme_icon(&"ImportCheck", &"EditorIcons")
    self._set_license_filepath_button.pressed.connect(self._on_set_license_filepath_clicked)
    self._license_file_edit.text_submitted.connect(self._on_data_file_edit_changed)
    self._license_file_edit.text = Licenses.get_license_data_filepath()

    self._li = LicensesInterface.get_interface()
    self._li.cfg_path_changed.connect(self._on_cfg_file_changed)

    self._components_tree.component_selected.connect(self._on_component_tree_selected)
    self._components_tree.component_remove.connect(self._on_component_tree_remove)
    self._components_tree.component_add.connect(self._on_component_tree_add)

    self._component_detail_tree.component_edited.connect(self._on_component_detail_edited)
    self._component_detail_tree.handlers = [ObjectHandler, StringFileHandler, StringMultiLineHandler, StringHandler, ArrayHandler]

    self._toolbar.add_component.connect(self._on_toolbar_add_component)
    self._toolbar.show_engine_components.connect(self._on_toolbar_show_engine_components)

    self._current_indentation = self._get_license_indentation()
    ProjectSettings.settings_changed.connect(self._on_project_settings_changed)
    self._update_set_license_filepath_button()
    self._li.components_changed.connect(self._on_components_changed)

func reload() -> void:
    self._update_set_license_filepath_button()
    var res: Licenses.LoadResult = self._li.load_licenses(self._license_file_edit.text)
    if res.err_msg == "":
        self._license_file_edit.right_icon = null
        self._license_file_edit.tooltip_text = ""
    else:
        self._license_file_edit.right_icon = self.get_theme_icon(&"NodeWarning", &"EditorIcons")
        self._license_file_edit.tooltip_text = res.err_msg

func show_component(comp: Component) -> void:
    self._components_tree.select_component(comp)
    self._component_detail_tree.set_component(comp)

func _update_set_license_filepath_button() -> void:
    if Licenses.get_license_data_filepath() == self._license_file_edit.text:
        self._set_license_filepath_button.icon = self.get_theme_icon(&"ImportCheck", &"EditorIcons")
        self._set_license_filepath_button.tooltip_text = "Selected file is set as the project license file."
        self._set_license_filepath_button.disabled = true
    else:
        self._set_license_filepath_button.icon = self.get_theme_icon(&"ImportFail", &"EditorIcons")
        self._set_license_filepath_button.tooltip_text = "Set the current file as project license file."
        self._set_license_filepath_button.disabled = false

func _on_data_file_load_button_clicked() -> void:
    var dialog: EditorFileDialog = EditorFileDialog.new()
    self.add_child(dialog)
    dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
    dialog.current_path = self._license_file_edit.text
    dialog.filters = ["*.json ; JSON files"]
    dialog.close_requested.connect(dialog.queue_free)
    dialog.file_selected.connect(self._on_data_file_selected)
    dialog.popup_centered_ratio(0.4)

func _on_data_file_edit_changed(new_text: String) -> void:
    self._on_data_file_selected(new_text)

func _on_data_file_selected(path: String) -> void:
    self._license_file_edit.text = path
    self.reload()

func _on_set_license_filepath_clicked() -> void:
    self._li.set_cfg_path(self._license_file_edit.text)
    self._update_set_license_filepath_button()

func _on_component_tree_selected(comp: Component) -> void:
    self._component_detail_tree.set_component(comp)

func _on_component_tree_add(comp: Component) -> void:
    self._li.add_component(comp)
    self._component_detail_tree.set_component(comp)
    self._li.emit_components_changed()

func _on_component_tree_remove(comp: Component) -> void:
    self._li.remove_component(comp)
    self._li.sort_custom(Licenses.compare_components_ascending)
    # refresh detail view if the current component was removed
    if comp == self._component_detail_tree.get_component():
        self._component_detail_tree.set_component(null)
    self._li.emit_components_changed()

func _on_toolbar_add_component(comp: Component) -> void:
    self._on_component_tree_add(comp)

func _on_toolbar_show_engine_components(show_: bool) -> void:
    self._components_tree.show_readonly_components = show_

# callback from component detail tree
func _on_component_detail_edited(_component: Component) -> void:
    self._li.sort_custom(Licenses.compare_components_ascending)
    # we cannot reload the tree while it is processing any kind of input/signals
    # https://github.com/godotengine/godot/issues/50084
    self._emit_components_changed.call_deferred()

func _on_components_changed() -> void:
    Licenses.save(self._li.components(), self._license_file_edit.text, _get_license_indentation())
    self._component_detail_tree.reload()
    self._components_tree.reload(self._component_detail_tree.get_component())

func _emit_components_changed():
    self._li.emit_components_changed()

func _on_cfg_file_changed(new_path: String) -> void:
    self._license_file_edit.text = new_path
    self._update_set_license_filepath_button()

func _on_project_settings_changed() -> void:
    var cur_indentation: String = _get_license_indentation()
    if self._current_indentation != cur_indentation:
        self._current_indentation = cur_indentation
        Licenses.save(self._components.components(), self._license_file_edit.text, _get_license_indentation())

enum IndentationType {
    NONE,
    SPACES,
    TABS
}

static func _get_license_indentation() -> String:
    var indentation: IndentationType = IndentationType.NONE
    # does not work due to https://github.com/godotengine/godot/issues/56598
    if ProjectSettings.has_setting(Licenses.CFG_KEY_INDENTATION):
        indentation = ProjectSettings.get_setting(Licenses.CFG_KEY_INDENTATION)
    else:
        indentation = IndentationType.NONE
    match indentation:
        IndentationType.NONE:
            return ""
        IndentationType.SPACES:
            return "    "
        IndentationType.TABS:
            return "\t"
    return ""
