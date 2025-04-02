extends RefCounted
## FLow have complete access to Tolgee object and will also access private properties.
## It is required to call finish() to free this object.
## _init will increase the reference counter and finish will decrease it. In this way the object has not tbe be saved in any way.

const Tolgee := preload("res://addons/kenyoni/tolgee/internal/scripts/tolgee.gd")

signal completed(err: Error)

var _tolgee: Tolgee = null

func _init(tolgee: Tolgee) -> void:
    self._tolgee = tolgee
    self.reference()

func run() -> void:
    pass

func finish() -> void:
    self.unreference()
