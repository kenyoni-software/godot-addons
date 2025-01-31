extends PanelContainer

const Component := preload("res://addons/licenses/component.gd")
const Licenses := preload("res://addons/licenses/licenses.gd")
const LicenseContainer := preload("res://examples/licenses/license_container.gd")

## First example with tree.
@export var _tree: Tree
## Second example with item list.
@export var _item_list: ItemList

## Container to display the license details.
@export var _license_container: LicenseContainer

func _ready() -> void:
    # load licenses
    var res: Licenses.LoadResult = Licenses.load(Licenses.get_license_data_filepath())
    if res.err_msg != "":
        return
    var components: Array[Component] = res.components
    # add engine licenses
    components.append_array(Licenses.get_required_engine_components())
    # sort licenses by category and name ascending
    # if you want the engine license in front of all other, append them in front after sorting
    components.sort_custom(Licenses.new().compare_components_ascending)

    # first example
    self._populate_tree(components)
    # second example
    self._populate_item_list(components)

## first example with tree
func _populate_tree(components: Array[Component]) -> void:
    # if an item in the tree is selected, set the license container's component to the selected component
    self._tree.item_selected.connect(self._on_tree_item_selected)

    # populate the tree node
    # create a category cache to easily access already created category items
    var category_cache: Dictionary[String, TreeItem] = {}
    var root: TreeItem = self._tree.create_item(null)
    category_cache[""] = root

    # add each component to the tree
    for component: Component in components:
        var parent: TreeItem = self._create_category_item(category_cache, component.category, root)
        var item: TreeItem = self._tree.create_item(parent)
        item.set_text(0, component.name)
        item.set_meta("component", component)

## create a category item in the tree
func _create_category_item(category_cache: Dictionary[String, TreeItem], category: String, root: TreeItem) -> TreeItem:
    if category in category_cache:
        return category_cache[category]
    var category_item: TreeItem
    category_item = self._tree.create_item(root)
    category_item.set_text(0, category)
    category_item.set_selectable(0, false)
    category_cache[category] = category_item
    return category_item

## second example with item list
func _populate_item_list(components: Array[Component]) -> void:
    # if an item in the item list is selected, set the license container's component to the selected component
    self._item_list.item_selected.connect(self._on_item_list_selected)

    # add each component to the item list
    for component: Component in components:
        self._item_list.add_item(component.name)
        self._item_list.set_item_metadata(self._item_list.item_count - 1, component)

## update the license display container to show the selected license
func _on_tree_item_selected() -> void:
    self._license_container.set_component(self._tree.get_selected().get_meta("component"))

func _on_item_list_selected(idx: int) -> void: 
    self._license_container.set_component(self._item_list.get_item_metadata(idx))
