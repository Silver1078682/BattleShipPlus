class_name ActionSubmarineMove
extends ActionMove

func _get_move_radius() -> int:
	var radius := super()
	if _ship.is_exposed():
		radius -= 1
	return radius
