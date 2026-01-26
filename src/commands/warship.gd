extends Node
## Commands

func _init() -> void:
	LimboConsole.register_command(_warship, "warship", "warship management")
	LimboConsole.register_command(_warship_list, "warship ls", "list all types of warship")
	LimboConsole.register_command(_warship_add, "warship add", "add warship")
	LimboConsole.add_argument_autocomplete_source("warship add", 1, func(): return Warship.NAMES)
	LimboConsole.register_command(_warship_remove, "warship remove", "remove warship")


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
	warship.coord = coord
	if not Player.fleet.has_ship_at(coord):
		Player.fleet.add_ship(warship, true)


func _warship_remove(at: Vector2i) -> void:
	Player.fleet.get_ship_at(at).leave_stage()


static func get_name_match(to_match: String, list: PackedStringArray) -> String:
	var candidate := ""
	for option in list:
		if option.to_lower().begins_with(to_match.to_lower()):
			if candidate:
				return ""
			candidate = option
	return candidate
