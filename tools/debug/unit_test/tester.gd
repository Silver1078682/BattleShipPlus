class_name Tester
extends Node

@export var enabled := true
@export var auto_start := false


func _ready() -> void:
	if auto_start:
		Game.instance.setup.connect(run)


func run() -> void:
	if not OS.is_debug_build():
		return
	if enabled:
		_run()


func _run() -> void:
	pass
