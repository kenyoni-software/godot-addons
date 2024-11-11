extends EditorContextMenuPlugin

const Component := preload("res://addons/licenses/component.gd")
const LicensesInterface := preload("res://addons/licenses/internal/plugin/licenses_interface.gd")

var _li: LicensesInterface

func _init() -> void:
    self._li = LicensesInterface.get_interface()

func _popup_menu(paths: PackedStringArray) -> void:
    if paths.size() == 1:
        var comps: Array[Component] = self._li.get_components_in_path(paths[0])
        if comps.size() > 0:
            for comp: Component in comps:
                self.add_context_menu_item("Show license (" + comp.name + ")", self._on_single_ctx_menu_clicked.bind(comp))

func _on_single_ctx_menu_clicked(_paths: PackedStringArray, comp: Component) -> void:
    self._li.show_popup(comp)
