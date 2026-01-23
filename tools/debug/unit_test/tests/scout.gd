extends Tester

func run() -> void:
	Attack.create_from_name("ScoutAircraft").launch(Map.instance.get_coords())
	pass
