extends VBoxContainer

@export var aspect_ratio: AspectRatioContainer
@export var aspect_resize: AspectRatioResizeContainer

@export var ar_height: SplitContainer
@export var ar_width: SplitContainer
@export var as_height: SplitContainer
@export var as_width: SplitContainer

func _on_ratio_value_changed(value: float) -> void:
    self.aspect_ratio.ratio = value
    self.aspect_resize.ratio = value

func _on_stretch_mode_item_selected(index: int) -> void:
    self.aspect_ratio.stretch_mode = index as AspectRatioContainer.StretchMode
    self.aspect_resize.stretch_mode = index as AspectRatioContainer.StretchMode

func _on_hor_align_item_selected(index: int) -> void:
    self.aspect_ratio.alignment_horizontal = index as AspectRatioContainer.AlignmentMode
    self.aspect_resize.alignment_horizontal = index as AspectRatioContainer.AlignmentMode

func _on_ver_align_item_selected(index: int) -> void:
    self.aspect_ratio.alignment_vertical = index as AspectRatioContainer.AlignmentMode
    self.aspect_resize.alignment_vertical = index as AspectRatioContainer.AlignmentMode

func _ready() -> void:
    self.ar_height.dragged.connect(self._on_ar_height_dragged)
    self.ar_width.dragged.connect(self._on_ar_width_dragged)
    self.as_height.dragged.connect(self._on_as_height_dragged)
    self.as_width.dragged.connect(self._on_as_width_dragged)

func _on_ar_height_dragged(offset: int) -> void:
    self.as_height.split_offset = offset

func _on_ar_width_dragged(offset: int) -> void:
    self.as_width.split_offset = offset

func _on_as_height_dragged(offset: int) -> void:
    self.ar_height.split_offset = offset

func _on_as_width_dragged(offset: int) -> void:
    self.ar_width.split_offset = offset
