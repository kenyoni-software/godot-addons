@tool
extends VBoxContainer

const Tolgee := preload("res://addons/kenyoni/tolgee/internal/scripts/tolgee.gd")

enum TreeButtonID {
    FileSelect,
    OutputSelect,
    Delete
}

@export var _host: LineEdit
@export var _api_key: LineEdit
@export var _show_api_key: Button
@export var _files: Tree
@export var _add_translation_button: Button

var _editor_file_dialog: EditorFileDialog

func _ready() -> void:
    self._show_api_key.icon = self.get_theme_icon(&"GuiVisibilityHidden", &"EditorIcons")

    self._editor_file_dialog = EditorFileDialog.new()
    self.add_child(self._editor_file_dialog)

    self._files.set_column_title(0, "File")
    self._files.set_column_expand(0, true)
    self._files.set_column_title(1, "Output")
    self._files.set_column_expand(1, true)
    self._files.set_column_title(2, "Placeholder")
    self._files.set_column_expand(2, false)
    self._files.set_column_expand(3, false)

    self._update_ui()

    self._show_api_key.toggled.connect(self._on_show_api_key_toggled)
    self._host.text_changed.connect(func(text: String) -> void: ProjectSettings.set_setting(Tolgee.CFG_KEY_HOST, text); ProjectSettings.save())
    self._api_key.text_changed.connect(func(text: String) -> void: ProjectSettings.set_setting(Tolgee.CFG_KEY_API_KEY, text); ProjectSettings.save())
    self._add_translation_button.pressed.connect(self._on_add_translation_pressed)
    self._files.button_clicked.connect(self._on_files_button_clicked)
    self._files.item_edited.connect(self._on_files_edited)

    self._files.clear()
    self._files.create_item()
    for tr_cfg: Dictionary in Tolgee.interface().files():
        self._add_translation(tr_cfg)

    Tolgee.interface().validated.connect(self._on_client_validated)

func _add_translation(tr_cfg: Dictionary) -> void:
    var item: TreeItem = self._files.create_item()
    item.set_meta("resource", tr_cfg)
    item.set_editable(0, true)
    item.set_text(0, tr_cfg.get("input_path", ""))
    item.add_button(0, self.get_theme_icon(&"FileBrowse", &"EditorIcons"), TreeButtonID.FileSelect, false, "Select translation file.")
    item.set_editable(1, true)
    item.set_text(1, tr_cfg.get("output_path"))
    item.set_editable(2, true)
    item.set_cell_mode(2, TreeItem.CELL_MODE_RANGE)
    item.set_text(2, ",".join(Tolgee.PLACEHOLDERS.map(func(placeholder: String) -> String: return placeholder.to_upper())))
    item.set_range(2, Tolgee.PLACEHOLDERS.find(tr_cfg.placeholder))
    item.set_tooltip_text(2, "ICU {value}: ICU (International Components for Unicode) Message Format\nPHP %s: This format is standard for PHP localization using Gettext (.po).")
    item.add_button(3, self.get_theme_icon(&"Remove", &"EditorIcons"), TreeButtonID.Delete, false, "Delete this entry.")
    match tr_cfg.get("input_path", "").get_extension():
        "csv":
            item.add_button(1, self.get_theme_icon(&"FileBrowse", &"EditorIcons"), TreeButtonID.OutputSelect, false, "Select output file.")
        "pot":
            item.add_button(1, self.get_theme_icon(&"FolderBrowse", &"EditorIcons"), TreeButtonID.OutputSelect, false, "Select output directory.")

func _update_ui() -> void:
    self._host.text = Tolgee.interface().host()
    self._api_key.text = ProjectSettings.get_setting(Tolgee.CFG_KEY_API_KEY, "")
    # TODO: update all tree items

func _reset_editor_file_dialog() -> void:
    for conn: Dictionary in self._editor_file_dialog.file_selected.get_connections():
        self._editor_file_dialog.file_selected.disconnect(conn["callable"] as Callable)
    for conn: Dictionary in self._editor_file_dialog.dir_selected.get_connections():
        self._editor_file_dialog.dir_selected.disconnect(conn["callable"] as Callable)
    self._editor_file_dialog.current_dir = ""
    self._editor_file_dialog.current_path = ""
    self._editor_file_dialog.current_file = ""
    self._editor_file_dialog.clear_filters()

func _on_add_translation_pressed() -> void:
    self._reset_editor_file_dialog()
    self._editor_file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
    self._editor_file_dialog.add_filter("*.csv", "CSV Translations")
    self._editor_file_dialog.add_filter("*.pot", "Portable Object Template files")
    self._editor_file_dialog.file_selected.connect(self._on_add_translation_file_selected)
    self._editor_file_dialog.popup_centered_ratio(0.4)

func _on_add_translation_file_selected(path: String) -> void:
    var tr_cfg: Dictionary = {
        "input_path": path,
        "output_path": "",
        "placeholder": Tolgee.PLACEHOLDERS[0]
    }
    if path.ends_with(".csv"):
        tr_cfg["output_path"] = path
    elif path.ends_with(".pot"):
        tr_cfg["output_path"] = path.get_base_dir()
    else:
        EditorInterface.get_editor_toaster().push_toast("Invalid file type", EditorToaster.SEVERITY_WARNING, "The selected file is not a valid translation file.")
        return

    if Tolgee.interface().add_translation_file(tr_cfg):
        self._add_translation(tr_cfg)
    self._update_ui()

func _on_client_validated(_err_msg: String) -> void:
    self._update_ui()

func _on_show_api_key_toggled(toggled: bool) -> void:
    self._api_key.secret = !toggled
    if toggled:
        self._show_api_key.icon = self.get_theme_icon(&"GuiVisibilityVisible", &"EditorIcons")
    else:
        self._show_api_key.icon = self.get_theme_icon(&"GuiVisibilityHidden", &"EditorIcons")

func _on_files_edited() -> void:
    var item: TreeItem = self._files.get_edited()
    if item == null:
        return
    var column: int = self._files.get_edited_column()
    var tr_cfg: Dictionary = item.get_meta("resource")
    match column:
        0:
            tr_cfg.file_path = item.get_text(0)
        1:
            tr_cfg.output_path = item.get_text(1)
        2:
            tr_cfg.placeholder = Tolgee.PLACEHOLDERS[int(item.get_range(2))]
    ProjectSettings.save()

func _on_files_button_clicked(item: TreeItem, _column: int, button_id: int, mouse_button_index: int) -> void:
    if mouse_button_index != MOUSE_BUTTON_LEFT:
        return
    if button_id == TreeButtonID.FileSelect || button_id == TreeButtonID.OutputSelect:
        var tr_cfg: Dictionary = item.get_meta("resource")
        self._reset_editor_file_dialog()
        match button_id:
            TreeButtonID.FileSelect:
                self._editor_file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
                self._editor_file_dialog.current_path = tr_cfg.get("input_path", "")
                match tr_cfg.get("input_path", "").get_extension():
                    "csv":
                        self._editor_file_dialog.add_filter("*.csv", "CSV Translations")
                    "pot":
                        self._editor_file_dialog.add_filter("*.pot", "Portable Object Template files")
                self._editor_file_dialog.file_selected.connect(func(path: String) -> void: tr_cfg["input_path"] = path; ProjectSettings.save())
                self._editor_file_dialog.popup_centered_ratio(0.4)
                return
            TreeButtonID.OutputSelect:
                match tr_cfg.get("input_path", "").get_extension():
                    "csv":
                        self._editor_file_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
                        self._editor_file_dialog.current_path = tr_cfg.get("output_path", "")
                        self._editor_file_dialog.add_filter("*.csv", "CSV Translations")
                    "pot":
                        self._editor_file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
                        self._editor_file_dialog.current_path = tr_cfg.get("output_path", "")
                self._editor_file_dialog.file_selected.connect(func(path: String) -> void: tr_cfg["output_path"] = path; ProjectSettings.save())
                self._editor_file_dialog.popup_centered_ratio(0.4)
                return
    if button_id == TreeButtonID.Delete:
        Tolgee.interface().remove_translation_file(item.get_meta("resource").get("input_path", ""))
        item.free()
