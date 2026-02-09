class_name ActionArtilleryAttack
extends ActionAttack

func _get_action_damage() -> int:
	return _ship.config.artillery_level + 1


func _launch_attack() -> Attack:
	var attack := _get_attack()
	var coords := _get_attack_damages()
	# note that the local attack only play the animation and does not affect the game state
	_play_attack_anim(coords, attack)

	var distance := HexGrid.distance(attack.center, _ship.coord)
	if _get_attack_result(distance, attack.dice_result) == Attack.Result.FAILURE:
		attack.result = Attack.Result.FAILURE
		return null

	attack.meta["artillery_level"] = _ship.config.artillery_level
	attack.launch(coords)
	return attack

	#default one as below, for reference
	#var attack := _get_attack()
	#var coords := _get_attack_damages()
	#_play_attack_anim(coords, attack)
	#attack.launch(coords)
	#return attack


func _get_attack_result(distance: int, dice_result: int) -> Attack.Result:
	if distance >= 3 and dice_result < 4:
		return Attack.Result.FAILURE
	if distance >= 2 and dice_result < 3:
		return Attack.Result.FAILURE
	if distance >= 1 and dice_result < 2:
		return Attack.Result.FAILURE
	return Attack.Result.SUCCESS
