extends Tester

static var TYPE_COUNT := Warship.NAMES.size()


func _run() -> void:
	var rect = get_spawn_rect(Vector2i.ONE)
	for coord in rect.get_coords():
		if not Map.instance.has_coord(coord):
			rect = get_spawn_rect(-Vector2i.ONE)
			break

	var coords = rect.get_coords().keys()
	for i in TYPE_COUNT:
		_add_warship(coords[i], Warship.NAMES[i])


func get_spawn_rect(direction) -> AreaRect:
	var rect := AreaRect.new()
	rect.size = direction * ceili(sqrt(TYPE_COUNT))
	rect.offset = Map.instance.get_base().coord + direction
	return rect
