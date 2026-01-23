extends Tester

func _run() -> void:
	var type_count := Warship.NAMES.size()
	var rect = AreaRect.new()
	rect.size = Vector2i.ONE * (type_count + 1)
	var coords = rect.get_coords().keys()
	for i in type_count:
		_add_warship(coords[i], Warship.NAMES[i])
