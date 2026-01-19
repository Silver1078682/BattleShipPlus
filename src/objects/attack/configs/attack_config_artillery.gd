class_name AttackConfigArtillery
extends AttackConfig

func _handle_attack(
		attack_damages: Dictionary,
		attack: Attack,
) -> Attack.Result:
	var attack_level: int = attack.meta["artillery_level"]

	for coord in attack_damages:
		var damage := _get_damage(coord, attack_level)
		attack_damages[coord] = damage

	super(attack_damages, attack)
	return Attack.Result.SUCCESS


func _get_damage(coord: Vector2i, attack_level: int) -> int:
	var ship := Player.fleet.get_ship_at(coord)
	if ship == null:
		return 0
	return max(0, 1 + attack_level - ship.config.artillery_level)
