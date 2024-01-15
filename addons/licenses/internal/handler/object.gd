extends "res://addons/licenses/internal/handler/base.gd"

const Utils := preload("res://addons/licenses/internal/utils.gd")

func _init(tree_: ComponentDetailTree, item_: TreeItem, value_: Variant, property_: Dictionary) -> void:
    super._init(tree_, item_, value_, property_)
    self.item.set_text(0, self.property["name"].capitalize())
    self.item.set_selectable(1, false)

    for prop: Dictionary in Utils.get_updated_property_list(self.value):
        # ignore private variables and ignore non supported types and already added items
        if prop["name"].begins_with("_"):
            continue
        self.tree._add_item(self.item, (self.value as Object).get(prop["name"]), prop)

static func can_handle(property: Dictionary) -> bool:
    return property["type"] == TYPE_OBJECT && property.get("class_name", "") != "Script"

func child_edited(item: TreeItem) -> void:
    var child = item.get_meta("handler")
    (self.value as Object).set(child.property["name"], child.value)
    self.tree._on_item_edited(self.item)
