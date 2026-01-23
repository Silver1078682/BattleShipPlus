class_name Tester
extends Node

@export var enabled := true
@export var auto_start := false


func _ready() -> void:
	if auto_start:
		Game.instance.setup.connect(run)


func run() -> void:
	if OS.is_debug_build() and enabled:
		_run()


func _run() -> void:
	pass


#-----------------------------------------------------------------#
## below are some util functions
func _add_warship(coord: Vector2i, warship_name: String) -> void:
	var warship := Warship.create_from_name(warship_name)
	warship.coord = coord
	if not Player.fleet.has_ship_at(coord):
		Player.fleet.add_ship(warship, true)
