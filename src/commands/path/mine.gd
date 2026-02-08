extends Command

func _enter_tree() -> void:
	_add_command(_mine, "mine", "mine management")
	_add_command(_mine_add, "mine add", "add mine")
	_add_command(_mine_remove, "mine remove", "remove mine")


func _mine() -> void:
	_print_commands()


func _mine_add(coord: Vector2i) -> void:
	if Player.mine.has_mine_at(coord):
		return
	Player.mine.add_mine_at(coord)


func _mine_remove(coord: Vector2i) -> void:
	if not Player.mine.has_mine_at(coord):
		return
	Player.mine.remove_mine_at(coord)
