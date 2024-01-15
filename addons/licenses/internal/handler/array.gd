extends "res://addons/licenses/internal/handler/base.gd"

var _constructor: Callable

func _init(tree_: ComponentDetailTree, item_: TreeItem, value_: Variant, property_: Dictionary) -> void:
    super._init(tree_, item_, value_, property_)
    self.item.set_text(0, self.property["name"].capitalize())
    self.item.set_text(1, "[ " + str(len(self.value)) + " ]")
    self.item.set_text_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)
    self._update_reset_button()
    self.item.add_button(1, self.tree.get_theme_icon(&"Add", &"EditorIcons"), 1)
    self.item.add_button(1, self.tree.get_theme_icon(&"Remove", &"EditorIcons"), 2)

    match self._get_child_property("")["type"]:
        TYPE_STRING:
            self._constructor = func() -> String: return ""
        TYPE_OBJECT:
            self._constructor = self.property["constructor"]

    for idx: int in range(len(self.value)):
        self.tree._add_item(self.item, self.value[idx], self._get_child_property(str(idx)))

func _get_child_property(name: String) -> Dictionary:
    var type: int = TYPE_NIL
    match self.property["type"]:
        TYPE_PACKED_STRING_ARRAY:
            type = TYPE_STRING
    if self.property["type"] == TYPE_ARRAY && self.property.get("constructor") != null:
        type = TYPE_OBJECT
    return {"name": name, "type": type, "hint": self.property.get("hint", PROPERTY_HINT_NONE), "hint_text": self.property.get("hint_text", ""), "constructor": self.property.get("constructor", null)}

static func can_handle(property: Dictionary) -> bool:
    return property["type"] == TYPE_PACKED_STRING_ARRAY || property["type"] == TYPE_ARRAY && property.get("constructor") != null

func _update_reset_button() -> void:
    var button_id: int = self.item.get_button_by_id(0, 0)
    if !self.value.is_empty() && button_id == -1:
        self.item.add_button(0, self.tree.get_theme_icon(&"Reload", &"EditorIcons"), 0)
    elif self.value.is_empty() && button_id != -1:
        self.item.erase_button(0, button_id)

func button_clicked(column: int, id: int, mouse_button_idx: int) -> void:
    match id:
        # reset array
        0:
            self.value = []
            var next_item: TreeItem = self.item.get_first_child()
            while next_item != null:
                self.item.remove_child(next_item)
                var tmp_item: TreeItem = next_item.get_next()
                next_item.free()
                next_item = tmp_item
            self._update_reset_button()
            self.tree._on_item_edited(self.item)
        # add
        1:
            var value: Variant = self._constructor.call()
            self.value.append(value)
            self.tree._add_item(self.item, value, self._get_child_property(str(len(self.value) - 1)))
            self._update_reset_button()
            self.tree._on_item_edited(self.item)
        # remove
        2:
            var selected_item: TreeItem = self.tree._selected_item
            if selected_item == null || selected_item.get_parent() != self.item:
                return
            self.value.remove_at(int(selected_item.get_text(0)))

            var next_item: TreeItem = selected_item.get_next()
            while next_item != null:
                var new_name: String = str(int(next_item.get_text(0)) - 1)
                next_item.set_text(0, new_name)
                next_item.get_meta("handler").property["name"] = new_name
                next_item = next_item.get_next()

            self.item.select(0)
            self.item.remove_child(selected_item)
            selected_item.free()
            self._update_reset_button()
            self.tree._on_item_edited(self.item)

func child_edited(item: TreeItem) -> void:
    var child = item.get_meta("handler")
    self.value[int(child.property["name"])] = child.value
    self.tree._on_item_edited(self.item)
