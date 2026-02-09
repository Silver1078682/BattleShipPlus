class_name ActionTorpedoAttack
extends ActionAttack

#-----------------------------------------------------------------#
func _committed() -> bool:
	var result := super()
	if result:
		_ship.torpedo -= 1
	return result


func _get_attack() -> Attack:
	var attack := super()
	attack.meta["direction"] = Cursor.coord - attack_area.offset
	return attack


func _update_cursor(p_coord: Vector2i, cursor: Cursor) -> void:
	if attack_area is AreaLine:
		attack_area.end = Cursor.coord - attack_area.offset
	super(p_coord, cursor)


## TODO remove it !!
func _get_attack_damages() -> Dictionary[Vector2i, int]:
	var damages := super()
	damages.erase(_ship.coord)
	return damages


func has_reached_commit_limit() -> bool:
	return super() or _ship.torpedo <= 0
