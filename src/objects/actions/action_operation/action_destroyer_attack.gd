class_name ActionDestroyerAttack
extends ActionAttack

func _get_action_area() -> Dictionary[Vector2i, int]:
	if not action_area:
		return { }
	var result: Dictionary[Vector2i, int] = { }
	for coord in action_area.get_coords():
		var opponent_ship := Opponent.fleet.get_ship_at(coord)
		if opponent_ship and opponent_ship.config.name == Warship.SUBMARINE:
			result[coord] = 0
	return result
