class_name ActionMove
extends ActionOperation

func _get_action_area() -> Dictionary[Vector2i, int]:
	if action_area is AreaHex:
		action_area.radius = _get_move_radius()
	else:
		Log.warning("ActionMove %s with action_area set a non-AreaHex")
	return action_area.get_coords()


func _get_move_radius() -> int:
	return _ship.config.motility if _ship else 0

#-----------------------------------------------------------------#
var _previous_coord: Vector2i


func _committed() -> bool:
	if not Game.instance.cursor.is_valid(true):
		return false

	_previous_coord = _ship.coord
	return _move_ship_to(Cursor.coord)


func _reverted() -> bool:
	return _move_ship_to(_previous_coord)


#-----------------------------------------------------------------#
func _started() -> void:
	pass
	#if not _line:
	#_line = Line2D.new()
	#_ship.add_child(_line)


#-----------------------------------------------------------------#
func _move_ship_to(target: Vector2i) -> bool:
	if Player.fleet.has_ship_at(target):
		Anim.pop_up("OCCUPIED")
		return false
	if Player.fleet.move_ship_to(ship, target):
		ship.coord = target
		return true
	return false
