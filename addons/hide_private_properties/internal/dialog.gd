@tool
extends Window

const Utils := preload("res://addons/hide_private_properties/utils.gd")

@export var _scan_button: Button
@export var _progress: ProgressBar

@export var _background_panel: Panel
@export var _warn_label: Label
@export var _label_panel: PanelContainer
@export var _info_label: Label
@export var _tree: Tree
@export var _tree_container: Control

var _scan_thread: Thread

func _ready() -> void:
    self._warn_label.add_theme_color_override(&"font_color", self.get_theme_color(&"warning_color", &"Editor"))
    self._background_panel.add_theme_stylebox_override(&"panel", self.get_theme_stylebox(&"Content", &"EditorStyles"))
    self._label_panel.add_theme_stylebox_override(&"panel", self.get_theme_stylebox(&"Background", &"EditorStyles"))

    self._tree.columns = 4
    self._tree.set_column_title(0, "Scene")
    self._tree.set_column_title(1, "Node")
    self._tree.set_column_title(2, "Property")
    self._tree.set_column_expand_ratio(0, 2)
    self._tree.set_column_expand_ratio(1, 1)
    self._tree.set_column_expand_ratio(2, 1)
    self._tree.set_column_expand(3, false)

    self._scan_button.pressed.connect(self._on_scan_button_pressed)
    self._tree.button_clicked.connect(self._on_tree_button_clicked)

func _scanning() -> void:
    var warnings: Array[PackedStringArray] = Utils.scan_path("res://")
    self._scan_finished.bind(warnings).call_deferred()

func _scan_finished(warnings: Array[PackedStringArray]) -> void:
    self._scan_thread.wait_to_finish()
    self._progress.visible = false
    if warnings.size() == 0:
        self._info_label.text = "No overridden private properties found!\nGood job!"
        return
    self._label_panel.visible = false
    self._tree_container.visible = true
    self._tree.create_item(null)
    for warning: PackedStringArray in warnings:
        var item: TreeItem = self._tree.create_item()
        item.set_text(0, warning[0])
        item.set_metadata(0, warning[0])
        item.set_text(1, warning[1].get_file())
        item.set_metadata(1, warning[1])
        item.set_text(2, warning[2])
        item.set_metadata(2, warning[2])
        item.set_tooltip_text(0, warning[0])
        item.set_tooltip_text(1, warning[1])
        item.set_tooltip_text(2, warning[2])
        item.add_button(3, self._tree.get_theme_icon(&"GuiVisibilityVisible", &"EditorIcons"), 0)
        item.set_button_tooltip_text(3, 0, "Show Node in Inspector")

func _on_scan_button_pressed() -> void:
    self._tree_container.visible = false
    self._tree.clear()
    self._label_panel.visible = true
    self._info_label.text = "Scanning..."
    self._progress.visible = true

    if self._scan_thread != null:
        if self._scan_thread.is_alive():
            return
        if self._scan_thread.is_started():
            self._scan_thread.wait_to_finish()

    self._scan_thread = Thread.new()
    self._scan_thread.start(self._scanning)

func _on_tree_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
    EditorInterface.open_scene_from_path(item.get_metadata(0) as String)
    EditorInterface.get_selection().clear()
    EditorInterface.get_selection().add_node(EditorInterface.get_edited_scene_root().get_node(item.get_metadata(1) as String))
