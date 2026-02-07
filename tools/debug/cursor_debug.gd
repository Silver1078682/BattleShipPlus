extends Node

#-----------------------------------------------------------------#
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_END:
			_debug_print("@" + str(Cursor.coord))
			for reason in Game.instance.cursor.invalid_check.keys():
				_debug_print("\t%s" % reason)
			_debug_print("AirD: %d" % Player.fleet.get_aerial_defense_level_at(Cursor.coord))
			_debug_ship(Player.fleet)
			_debug_ship(Opponent.fleet)
			_debug_mine(Player.mine)
			_debug_print("-".repeat(20))
			_debug_flush()


func _debug_mine(mine_manager: MineManager) -> void:
	if mine_manager.has_mine_at(Cursor.coord):
		var mine := mine_manager.get_mine(Cursor.coord)
		_debug_print(mine)


func _debug_ship(fleet: Fleet) -> void:
	if fleet.has_ship_at(Cursor.coord):
		var ship := fleet.get_ship_at(Cursor.coord)
		_debug_print(ship)
		for reason in ship.exposure_reasons:
			_debug_print("\t%s" % reason)
		for action in ship.get_actions():
			_debug_print("\t%s" % action)

#-----------------------------------------------------------------#
var _debug_string := ""


func _debug_print(variant) -> void:
	_debug_string += "\n"
	_debug_string += str(variant)


func _debug_flush():
	LimboConsole.print_line(_debug_string)
	Log.debug(_debug_string)
	_debug_string = ""
