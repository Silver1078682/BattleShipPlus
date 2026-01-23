class_name PhaseMovement
extends Phase

func _exit() -> void:
	## TODO??? Switch to more robust way
	var attack := Attack.create_from_name("Collision")
	attack.scouting = false
	attack.launch(Player.fleet.get_collision_damages())
