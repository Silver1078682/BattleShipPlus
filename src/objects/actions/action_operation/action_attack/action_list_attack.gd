class_name ActionListAttack
extends ActionAttack

@export var apply_list: Array[StringName]


func _get_cursor_check_list(p_coord: Vector2i) -> Dictionary[String, bool]:
	var list = super(p_coord)
	var opponent_ship := Opponent.fleet.get_ship_at(p_coord)
	if not opponent_ship:
		list["NO_WARSHIP"] = true
		return list
	var name := opponent_ship.config.name
	list["WARSHIP_IS_NOT_TYPE_OF"] = name in apply_list
	return list
