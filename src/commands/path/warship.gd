extends Command
## Commands

func _init() -> void:
	_add_command(_warship, "warship", "warship management")
	_add_command(_warship_list, "warship ls", "list all types of warship")
	_add_command(_warship_add, "warship add", "add warship")
	LimboConsole.add_argument_autocomplete_source("warship add", 1, func(): return Warship.NAMES)
	_add_command(_warship_remove, "warship remove", "remove warship")
	_add_command(_warship_kill, "warship kill", "kill warship")
	_add_command(_warship_all, "warship all", "add all type of warship")


#-----------------------------------------------------------------#
func _warship() -> void:
	_print_commands()


func _warship_list() -> void:
	LimboConsole.print_line("\n".join(Warship.NAMES))


func _warship_add(coord: Vector2i, warship_name: String) -> void:
	warship_name = get_name_match(warship_name, Warship.NAMES)
	if not warship_name:
		LimboConsole.warn("bad warship name")
		return
	var warship := Warship.create_from_name(warship_name)
	warship.coord = coord
	if not Player.fleet.has_ship_at(coord):
		Player.fleet.add_ship(warship, true)


func _warship_all(coord: Vector2i, dire: Vector2i) -> void:
	var type_count := Warship.NAMES.size()
	var a = ceili(sqrt(type_count))

	dire = dire.sign()
	var rect = AreaRect.new()
	rect.offset = coord + dire
	rect.size = dire * a

	var coords := rect.get_coords().keys()
	for i in type_count:
		_warship_add(coords[i], Warship.NAMES[i])


func _warship_remove(coord: Vector2i) -> void:
	if Player.fleet.has_ship_at(coord):
		Player.fleet.get_ship_at(coord).leave_stage()


func _warship_kill(coord: Vector2i) -> void:
	if Player.fleet.has_ship_at(coord):
		Player.fleet.get_ship_at(coord).health = 0
