extends RefCounted
## FLow have complete access to Tolgee object and will also access private properties.
## this object can be fired with run and forget. It will increase the reference count of Tolgee object and decrease it when finished.
## Therefore DO NOT CALL RUN TWICE without keeping an own reference to it.

const Tolgee := preload("res://addons/kenyoni/tolgee/internal/scripts/tolgee.gd")

signal completed(err: Error)

var _tolgee: Tolgee = null

func _init(tolgee: Tolgee) -> void:
    self._tolgee = tolgee

func run() -> void:
    self.reference()
    self.completed.connect(func(_err: Error) -> void: self._destruct(), CONNECT_ONE_SHOT)

func _destruct() -> void:
    self.unreference()
