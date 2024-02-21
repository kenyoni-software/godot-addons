extends PopupMenu

const Utils := preload("res://addons/icons_patcher/utils.gd")
const EditorToastNotification := preload("res://addons/icons_patcher/editor_toast_notification.gd")

func _ready() -> void:
    self.add_item("Patch Material Design Icons")

    self.id_pressed.connect(self._on_id_pressed)
    self.about_to_popup.connect(self._on_about_to_popup)

func _set_item_details(idx: int, settings_key: String, tooltip: String) -> void:
    var path: String = ProjectSettings.get_setting(settings_key)
    var can_use: bool = path != "" && DirAccess.dir_exists_absolute(path)
    self.set_item_disabled(idx, !can_use)
    if can_use:
        self.set_item_icon(idx, null)
        self.set_item_tooltip(idx, "")
    else:
        self.set_item_icon(idx, self.get_theme_icon(&"NodeWarning", &"EditorIcons"))
        self.set_item_tooltip(idx, tooltip)

func _on_about_to_popup() -> void:
    self._set_item_details(0, Utils.MDI_DIRECTORY_PATH, "Set Material Design Icons Directory in Project Settings!")

func _on_id_pressed(id: int) -> void:
    match id:
        0:
            self._patch_icons_material_design()

func _patch_icons_material_design() -> void:
    var base_path: String = ProjectSettings.get_setting(Utils.MDI_DIRECTORY_PATH)
    
    var rx: RegEx = RegEx.new()
    rx.compile('(" fill="#[a-fA-F0-9]{6})?">')
    var patched_icons: PackedStringArray = Utils.patch_icon_dir(base_path, rx, '" fill="#ffffff">')
    EditorInterface.get_resource_filesystem().reimport_files(patched_icons)
    EditorToastNotification.notify("[IconsPatcher] Patched " + base_path)
