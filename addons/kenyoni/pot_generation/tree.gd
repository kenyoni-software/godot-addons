@tool
extends Tree

const Utils := preload("res://addons/kenyoni/pot_generation/utils.gd")

enum _Buttons {
    Remove
}

## items are of the form [path, filter]
signal paths_changed(paths: Array[PackedStringArray])

@export var show_filtered_files: bool = false:
    set = set_show_filtered_files

func set_show_filtered_files(value: bool) -> void:
    show_filtered_files = value
    self._update_filtered_files()

func _init() -> void:
    self.set_column_title(0, "Path")
    self.set_column_expand_ratio(0, 4)
    self.set_column_title(1, "Filter")
    self.set_column_expand(1, true)
    self.set_column_expand(2, false)
    self.create_item()

func _ready() -> void:
    self.item_edited.connect(self._on_item_edited)
    self.button_clicked.connect(self._on_button_clicked)

func add_gen_item(path: String, filter: String):
    var item: TreeItem = self.create_item()
    item.set_text(0, path)
    item.set_text(1, filter)
    item.set_tooltip_text(0, path)
    item.set_tooltip_text(1, "\n".join(Utils.get_filter_from_string(filter)))
    item.set_editable(1, path.ends_with("/"))
    item.add_button(2, self.get_theme_icon(&"Remove", &"EditorIcons"), _Buttons.Remove)
    if self.show_filtered_files && path.ends_with("/"):
        self._add_filtered_files(item)
    self.paths_changed.emit(self.get_paths())

## Returns an array of path and filter pairs
func get_paths() -> Array[PackedStringArray]:
    var paths: Array[PackedStringArray] = []
    var tree_item: TreeItem = self.get_root().get_next_in_tree()
    while tree_item != null:
        paths.push_back(PackedStringArray([self._get_path(tree_item), self._get_filter_text(tree_item)]))
        tree_item = tree_item.get_next()
    return paths

func _get_path(item: TreeItem) -> String:
    return item.get_text(0)

func _get_filter_text(item: TreeItem) -> String:
    return item.get_text(1)

func _remove_children(item: TreeItem) -> void:
    var child: TreeItem = item.get_first_child()
    while child != null:
        item.remove_child(child)
        child.free()
        child = item.get_first_child()

func _update_filtered_files() -> void:
    var tree_item: TreeItem = self.get_root().get_next_in_tree()
    while tree_item != null:
        if !self._get_path(tree_item).ends_with("/"):
            tree_item = tree_item.get_next()
            continue
        if self.show_filtered_files:
            self._add_filtered_files(tree_item)
        else:
            self._remove_children(tree_item)
        tree_item = tree_item.get_next()

func _add_filtered_files(item: TreeItem) -> void:
    for file: String in Utils.get_filtered_files(self._get_path(item), Utils.get_filter_from_string(self._get_filter_text(item))):
        var sub_item: TreeItem = self.create_item(item)
        sub_item.set_text(0, file)
        sub_item.set_tooltip_text(0, file)

func _on_item_edited() -> void:
    var item: TreeItem = self.get_edited()
    if item == null:
        return
    item.set_tooltip_text(0, self._get_path(item))
    item.set_tooltip_text(1, "\n".join(Utils.get_filter_from_string(self._get_filter_text(item))))
    if self.show_filtered_files && self._get_filter_text(item).ends_with("/"):
        self._remove_children(item)
        self._add_filtered_files(item)
    self.paths_changed.emit(self.get_paths())

func _on_button_clicked(item: TreeItem, _column: int, id: int, mouse_button_index: int) -> void:
    if id == _Buttons.Remove && mouse_button_index == MOUSE_BUTTON_LEFT:
        self.get_root().remove_child(item)
        item.free()
        self.paths_changed.emit(self.get_paths())
