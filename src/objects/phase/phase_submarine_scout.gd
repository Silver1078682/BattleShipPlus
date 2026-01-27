class_name PhaseSubmarineScout
extends Phase

func _enter() -> void:
	for ship in Player.fleet.get_ships():
		if ship.config.name == Warship.DESTROYER:
			var attack = Attack.create_from_name("DestroyerScout")
			attack.center = ship.coord

			var area := AreaHex.new()
			area.radius = 2
			area.offset = ship.coord

			attack.launch(area.get_coords())
