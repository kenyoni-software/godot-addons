@tool
extends TextureRect

var _process_spinner_msec: float = 0
var _process_spinner_frame: int = 0

func _ready() -> void:
    self.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    self.texture = self.get_theme_icon(&"Progress1", &"EditorIcons")
    self.visibility_changed.connect(self._on_visibility_changed)

func _process(delta: float) -> void:
    self._process_spinner_msec += delta
    if self._process_spinner_msec > 0.2:
        self._process_spinner_msec = fmod(self._process_spinner_msec, 0.2)
        self._process_spinner_frame = (self._process_spinner_frame + 1) % 8
        self.texture = self.get_theme_icon("Progress" + str(self._process_spinner_frame + 1), &"EditorIcons")

func _on_visibility_changed() -> void:
    self.set_process(self.visible)
