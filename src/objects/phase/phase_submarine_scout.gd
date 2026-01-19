class_name PhaseSubmarineScout
extends Phase

func _enter() -> void:
	for coord in Player.fleet.get_coords():
		var ship := Player.fleet.get_ship_at(coord)
		if ship.config.name == Warship.DESTROYER:
			var attack = Attack.create_from_name("DestroyerScout")
			attack.center = coord
			var area := AreaHex.new()
			area.radius = 2
			attack.push(area.get_coords())
