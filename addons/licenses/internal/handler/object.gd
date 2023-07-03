extends "base.gd"

func _init(tree_: Tree, item_: TreeItem, value_: Variant, property_: Dictionary) -> void:
    super._init(tree_, item_, value_, property_)
    self.item.set_text(0, self.property["name"].capitalize())
    self.item.set_selectable(1, false)
    for prop in self.value.get_property_list():
        # ignore private variables and ignore non supported types
        if prop["name"].begins_with("_"):
            continue
        self.tree._add_item(self.item, self.value.get(prop["name"]), prop)

static func can_handle(property: Dictionary) -> bool:
    return property["type"] == TYPE_OBJECT and property.get("class_name", "") != "Script"

func child_edited(item: TreeItem) -> void:
    var child = item.get_meta("handler")
    self.value.set(child.property["name"], child.value)
    self.tree._on_item_edited(self.item)
