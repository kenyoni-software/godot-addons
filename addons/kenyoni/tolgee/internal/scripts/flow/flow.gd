extends RefCounted
## FLow has complete access to Tolgee object and will also access private properties.
## This object can be created, run and no reference has to be kept to it.

const Tolgee := preload("res://addons/kenyoni/tolgee/internal/scripts/tolgee.gd")

signal completed(err: Error)

var _tolgee: Tolgee = null

func _init(tolgee: Tolgee) -> void:
    self._tolgee = tolgee
    self.completed.connect(self._on_completed, CONNECT_ONE_SHOT)

## VIRTUAL
func run() -> void:
    self.reference()

func _on_completed(err: Error) -> void:
    self.unreference()
