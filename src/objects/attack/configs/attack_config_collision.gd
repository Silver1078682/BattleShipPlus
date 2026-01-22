class_name AttackConfigCollision
extends AttackConfig

func _handle_attack(
		attack_damages: Dictionary,
		attack: Attack,
) -> Attack.Result:
	var hit_ships := Player.fleet.get_hit_ships(attack_damages, attack)
	for coord in hit_ships:
		var warship := hit_ships[coord]
		var collision_attack := Attack.create_from_name("CollisionConfirm")
		collision_attack.meta["attacker_type"] = warship.config.name
		collision_attack.center = warship.coord
		collision_attack.push({ coord: warship.config.health * 2 })
	if hit_ships.is_empty():
		return Attack.Result.MISS
	return Attack.Result.SUCCESS
