class_name AttackConfigTorpedo
extends AttackConfig

const DAMAGE_ON_SURROUNDING_TILES = 6
static var _damage_reduction_modifier = func(x): return floori(x * 0.5)


func _handle_attack(
		attack_damages: Dictionary,
		attack: Attack,
) -> Attack.Result:
	attack.base_damage += attack.dice_result

	for coord: Vector2i in attack_damages:
		var coord_direction := coord - attack.center
		var attack_direction: Vector2i = attack.meta["direction"]
		## If the center of the cell go through the attack line
		if coord_direction.x * attack_direction.y != coord_direction.y * attack_direction.x:
			attack_damages[coord] = _damage_reduction_modifier.call(attack_damages[coord])
		if HexGrid.distance(coord, attack.center) <= 1:
			attack_damages[coord] = DAMAGE_ON_SURROUNDING_TILES - attack.base_damage

	super(attack_damages, attack)
	return Attack.Result.SUCCESS
