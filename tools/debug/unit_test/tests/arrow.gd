extends Tester

func _run():
	var opponent_base: Vector2i
	if Network.is_server():
		opponent_base = Map.instance.get_base(Player.CLIENT_ID).coord
	else:
		opponent_base = Map.instance.get_base(Player.HOST_ID).coord
	var my_base := Map.instance.get_base(Player.id).coord
	var dire := Vector2(opponent_base - my_base).normalized()
	var detect: Vector2 = my_base
	while Vector2i(detect) in Map.instance.get_scope_home():
		detect += dire
	var nearest_point := Vector2i(detect - dire)

	_add_warship(nearest_point, "Carrier")
	_add_warship(nearest_point - Vector2i(dire), "Carrier")
	_add_warship(nearest_point - Vector2i(dire) * 2, "Battleship")
	_add_warship(nearest_point - HexGrid.rotate_a_point(dire, 2), "Destroyer")
	_add_warship(nearest_point - HexGrid.rotate_a_point(dire, -2), "Destroyer")


func _add_warship(coord: Vector2i, warship_name: String) -> void:
	var warship := Warship.create_from_name(warship_name)
	warship.coord = coord
	if not Player.fleet.has_ship_at(coord):
		Player.fleet.add_ship(warship, true)
