class_name ActionAerialAttack
extends ActionAttack

func _get_attack() -> Attack:
	var attack := super()
	attack.meta["source_ship_id"] = _ship.id
	return attack
