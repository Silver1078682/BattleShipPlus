class_name ActionTorpedoAttack
extends ActionAttack

#-----------------------------------------------------------------#
func _started() -> void:
	pass


func _committed() -> bool:
	var result := super()
	if result:
		_ship.torpedo -= 1
	return result


func _get_attack(coord: Vector2i) -> Attack:
	var attack := super(coord)
	attack.meta["direction"] = Cursor.coord - attack_area.offset
	return attack


func _update_cursor(p_coord: Vector2i, cursor: Cursor) -> void:
	if attack_area is AreaLine:
		attack_area.end = Cursor.coord - attack_area.offset
	super(p_coord, cursor)


func _get_attack_damages(offset: Vector2i) -> Dictionary[Vector2i, int]:
	var damages := super(offset)
	damages.erase(_ship.coord)
	return damages
