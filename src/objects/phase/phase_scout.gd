class_name PhaseHydroplaneAttack
extends Phase

func _enter() -> void:
	for ship in Player.fleet.get_ships():
		if ship.config.name == "BB":
			var hex := AreaHex.new()
			hex.radius = 9 - 1 # attack_range - 1
			var attack := Attack.create_from_name("Default")
			attack.scouting = true
			attack.center = ship.coord
			attack.push(hex.get_coords())
