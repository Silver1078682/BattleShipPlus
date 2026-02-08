class_name AttackConfigAerial
extends AttackConfig

#-----------------------------------------------------------------#
## Push an aerial attack to the your opponent
func _push_attack(
		attack_damages: Dictionary[Vector2i, int],
		attack: Attack,
) -> void:
	super(attack_damages, attack)
	attack.finished.connect(_on_attack_finished.bind(attack))

#-----------------------------------------------------------------#
const ATTACK_FAILURE_PUNISHMENT = 1


## The attack source should be set as the id of the carrier
func _on_attack_finished(attack: Attack) -> void:
	if not attack.check_meta("source_ship_id"):
		return
	var source_ship_id: int = attack.meta["source_ship_id"]
	var warship: Warship = Player.fleet.get_node_or_null("Warship%s" % source_ship_id)
	if not warship:
		Log.error("Invalid warship id: %s" % source_ship_id)
	elif attack.result == Attack.Result.FAILURE:
		warship.health -= ATTACK_FAILURE_PUNISHMENT


func _handle_attack(
		attack_damages: Dictionary,
		attack: Attack,
) -> Attack.Result:
	var attack_result: Attack.Result

	# if attack center is at aerial_defense_map_layer
	if Map.instance.aerial_defense_map_layer.has_coord(attack.center):
		attack_result = Attack.Result.FAILURE
		var aerial_defense_areas := ActionAerialDefense.get_aerial_defense_areas()
		for area_coord in aerial_defense_areas:
			var area := aerial_defense_areas[area_coord]
			if area.has_point(attack.center):
				ActionAerialDefense.delete_aerial_defense_area_at(area_coord)
		ActionAerialDefense.update_map()

	else:
		var attack_level := attack.dice_result
		var defense_level := Player.fleet.get_aerial_defense_level_at(attack.center)
		Log.debug("handling aerial attack with attack_level %d, defense_level %d" % [attack_level, defense_level])

		if attack_level > defense_level:
			attack_result = Attack.Result.SUCCESS
			for coord in attack_damages:
				attack_damages[coord] = _get_success_damage(attack_damages[coord], attack, defense_level)
		elif attack_level > ceili(defense_level / 2.0):
			attack_result = Attack.Result.HALF_SUCCESS
			for coord in attack_damages:
				attack_damages[coord] = _get_half_success_damage(attack_damages[coord], attack, defense_level)
		else:
			attack_result = Attack.Result.FAILURE

	Log.debug("Attack ", Attack.Result.find_key(attack_result))
	if attack_result != Attack.Result.FAILURE:
		super(attack_damages, attack)

	return attack_result


#-----------------------------------------------------------------#
# The damage on success is raised from 1 by 2, namely 3, for TorpedoAircraft
# for DiveAircraft, see [AttackConfigDiveAircraft]
func _get_success_damage(_base_damage: int, _attack: Attack, _defense_level: int) -> int:
	return 2


func _get_half_success_damage(_base_damage: int, attack: Attack, _defense_level: int) -> int:
	return attack.base_damage
