extends Tester

func run() -> void:
	Attack.create_from_name("ScoutAircraft").push(Map.instance.get_coords())
	pass
