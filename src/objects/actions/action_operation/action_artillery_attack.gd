class_name ActionArtilleryAttack
extends ActionAttack

func _get_action_area() -> Dictionary[Vector2i, int]:
	if action_area is AreaHex:
		action_area.radius = _get_action_radius()
	else:
		Log.warning("ActionArtilleryAttack %s with action_area set a non-AreaHex")
	return action_area.get_coords()


func _get_action_radius() -> int:
	return _ship.config.artillery_distance


func _get_action_damage() -> int:
	return _ship.config.artillery_level + 1


func _attack_at(coord: Vector2i) -> Attack:
	var coords := _get_attack_damages(coord)
	var attack := Attack.create_from_config(attack_config)
	attack.center = coord
	_play_attack_anim(coords, attack)

	# note that the local attack only play the animation and does not affect the game state
	var distance := HexGrid.distance(coord, _ship.coord)
	var dice_result := attack.dice_result
	attack.result = _get_attack_result(distance, dice_result)
	if attack.result == Attack.Result.FAILURE:
		return null

	var remote_attack := Attack.create_from_config(attack_config)
	remote_attack.center = coord
	remote_attack.dice_result = dice_result
	remote_attack.meta["artillery_level"] = _ship.config.artillery_level
	remote_attack.launch(coords)
	return remote_attack


func _get_attack_result(distance: int, dice_result: int) -> Attack.Result:
	if distance >= 3 and dice_result < 4:
		return Attack.Result.FAILURE
	if distance >= 2 and dice_result < 3:
		return Attack.Result.FAILURE
	if distance >= 1 and dice_result < 2:
		return Attack.Result.FAILURE
	return Attack.Result.SUCCESS
