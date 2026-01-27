extends Tester

func _run() -> void:
	for attack_config: AttackConfig in ResourceUtil.load_directory("attacks"):
		var attack := Attack.create_from_config(attack_config)
		var opponent_id := 1 if Network.is_server() else 0
		attack.launch(get_spawn_rect(opponent_id).get_coords())
