extends Tester

func _run() -> void:
	var coords = get_spawn_rect().get_coords().keys()
	for i in TYPE_COUNT:
		_add_warship(coords[i], Warship.NAMES[i])
