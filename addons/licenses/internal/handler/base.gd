extends RefCounted

const ComponentDetailTree := preload("res://addons/licenses/internal/component_detail_tree.gd")

var tree: ComponentDetailTree
var item: TreeItem
var property: Dictionary
var value: Variant

func _init(tree_: ComponentDetailTree, item_: TreeItem, value_: Variant, property_: Dictionary) -> void:
    assert(item_ != null, "item must not null")
    self.tree = tree_
    self.item = item_
    self.property = property_
    self.value = value_
    self.item.set_meta("handler", self)
    self.item.custom_minimum_height = 16

static func can_handle(property: Dictionary) -> bool:
    return false

# return true if edited
func button_clicked(column: int, id: int, mouse_button_idx: int) -> void:
    pass

func child_edited(item: TreeItem) -> void:
    pass

func edited() -> void:
    pass

func selected() -> void:
    pass
