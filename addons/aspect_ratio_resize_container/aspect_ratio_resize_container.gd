@tool
extends AspectRatioContainer
class_name AspectRatioResizeContainer

func _notification(what: int) -> void:
    match what:
        NOTIFICATION_RESIZED, NOTIFICATION_THEME_CHANGED, NOTIFICATION_PRE_SORT_CHILDREN:
            self.custom_minimum_size = self._get_minimum_size()

func _set(property: StringName, value: Variant) -> bool:
    if property == "stretch_mode":
        self.custom_minimum_size = self._get_minimum_size()
    return false

func _get_children_min_size() -> Vector2:
    var min_size: Vector2 = Vector2.ZERO
    for child: Node in self.get_children():
        if !(child is Control) || !(child as Control).visible:
            continue
        var child_min: Vector2 = (child as Control).get_combined_minimum_size()
        min_size.x = maxf(min_size.x, child_min.x)
        min_size.y = maxf(min_size.y, child_min.y)
    return min_size

func _get_minimum_size() -> Vector2:
    var min_size: Vector2 = self._get_children_min_size()
    if self.stretch_mode == STRETCH_WIDTH_CONTROLS_HEIGHT:
        var width: float = maxf(min_size.x, self.size.x)
        min_size.y = width * self.ratio
    elif self.stretch_mode == STRETCH_HEIGHT_CONTROLS_WIDTH:
        var height: float = maxf(min_size.y, self.size.y)
        min_size.x = height * self.ratio
    return min_size
