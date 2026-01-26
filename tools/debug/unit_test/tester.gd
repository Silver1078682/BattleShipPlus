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


static var TYPE_COUNT := Warship.NAMES.size()


func get_spawn_rect(player_id := Player.id) -> AreaRect:
	var rect = _get_spawn_rect(Vector2i.ONE, player_id)
	for coord in rect.get_coords():
		if not Map.instance.has_coord(coord):
			rect = _get_spawn_rect(-Vector2i.ONE, player_id)
			break
	return rect


func _get_spawn_rect(direction, player_id) -> AreaRect:
	var rect := AreaRect.new()
	rect.size = direction * ceili(sqrt(TYPE_COUNT))
	rect.offset = Map.instance.get_base(player_id).coord + direction
	return rect
