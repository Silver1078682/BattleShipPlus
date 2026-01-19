extends Tester

@export var spawn_count: int


func _run():
	var arr := Map.instance.get_scope_public().keys()
	arr.shuffle()
	arr = arr.slice(0, spawn_count)
	for i: Vector2i in arr:
		_add_warship(i, "Submarine")


func _add_warship(coord: Vector2i, warship_name: String) -> void:
	var warship := Warship.create_from_name(warship_name)
	warship.coord = coord
	if not Player.fleet.has_ship_at(coord):
		Player.fleet.add_ship(warship, true)
