extends Tree

const Component := preload("res://addons/licenses/component.gd")
const Licenses := preload("res://addons/licenses/licenses.gd")
const LicenseContainer := preload("license_container.gd")

@export_node_path("Node") var _license_container_path; @onready var _license_container: LicenseContainer = self.get_node(_license_container_path)

var licenses: Array[Component] = []

func _ready() -> void:
    self.item_selected.connect(self._on_item_selected)
    var res: Licenses.LoadResult = Licenses.load(Licenses.get_license_data_filepath())
    if res.err_msg != "":
        return
    self.licenses = res.components
    self.licenses.append_array(Licenses.get_required_engine_components())
    self.licenses.sort_custom(Licenses.new().compare_components_ascending)

    # create items
    var category_cache: Dictionary = {}
    var root: TreeItem = self.create_item(null)
    category_cache[""] = root
    var idx: int = 0

    while idx < len(self.licenses):
        var component: Component = self.licenses[idx]
        self._add_component(component, category_cache, root, idx)
        idx = idx + 1

func _create_category_item(category_cache: Dictionary, category: String, root: TreeItem) -> TreeItem:
    if category in category_cache:
        return category_cache[category]
    var category_item: TreeItem
    category_item = self.create_item(root)
    category_item.set_text(0, category)
    category_item.set_selectable(0, false)
    category_cache[category] = category_item
    return category_item

func _add_tree_item(component: Component, idx: int, parent: TreeItem) -> TreeItem:
    var item: TreeItem = self.create_item(parent)
    item.set_text(0, component.name)
    item.set_meta("idx", idx)
    return item

func _add_component(component: Component, category_cache: Dictionary, root: TreeItem, idx: int) -> TreeItem:
    var parent: TreeItem = self._create_category_item(category_cache, component.category, root)
    return self._add_tree_item(component, idx, parent)

func _on_item_selected() -> void:
    self._license_container.set_component(self.licenses[self.get_selected().get_meta("idx")])
