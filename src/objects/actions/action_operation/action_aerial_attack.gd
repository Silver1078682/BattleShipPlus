class_name ActionAerialAttack
extends ActionAttack

func _get_attack(coord: Vector2i) -> Attack:
	var attack := super(coord)
	attack.meta["source_ship_id"] = _ship.id
	return attack
