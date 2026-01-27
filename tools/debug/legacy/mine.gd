extends Tester

func _run() -> void:
	var rect := AreaRect.new()
	rect.size = Vector2i.ONE * 3
	rect.offset -= Vector2i.ONE
	rect.shrink_edge = true
	for coord in rect.get_coords():
		_add_mine(coord)


func _add_mine(coord: Vector2i) -> void:
	Player.mine.add_mine_at(coord)
