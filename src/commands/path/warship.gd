extends Command
## Commands

func _init() -> void:
	_add_command(_warship, "warship", "warship management")
	_add_command(_warship_list, "warship ls", "list all types of warship")
	_add_command(_warship_add, "warship add", "add warship")
	LimboConsole.add_argument_autocomplete_source("warship add", 1, func(): return Warship.NAMES)
	_add_command(_warship_remove, "warship remove", "remove warship")


#-----------------------------------------------------------------#
func _warship() -> void:
	for sub: String in ["ls", "add"]:
		var full := "warship " + sub
		LimboConsole.print_line("%-20s%s" % [full, LimboConsole.get_command_description(full)])


func _warship_list() -> void:
	LimboConsole.print_line("\n".join(Warship.NAMES))


func _warship_add(coord: Vector2i, warship_name: String) -> void:
	var warship := Warship.create_from_name(warship_name)
	if not warship:
		LimboConsole.warn("bad warship name")
		return
	warship.coord = coord
	if not Player.fleet.has_ship_at(coord):
		Player.fleet.add_ship(warship, true)


func _warship_remove(coord: Vector2i) -> void:
	if Player.fleet.has_ship_at(coord):
		Player.fleet.get_ship_at(coord).leave_stage()
