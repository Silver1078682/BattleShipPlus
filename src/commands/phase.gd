extends Node
## Commands

func _init() -> void:
	LimboConsole.register_command(_phase, "phase", "phase management")
	LimboConsole.register_command(_phase_next, "phase next", "go to next phase")
	LimboConsole.register_command(_phase_list, "phase ls", "list all phases")
	LimboConsole.register_command(_phase_goto, "phase goto", "Go to certain phase")
	LimboConsole.add_argument_autocomplete_source("phase goto", 0, func(): return Phase.manager.phases.keys())


#-----------------------------------------------------------------#
func _phase() -> void:
	for sub: String in ["next", "ls", "goto"]:
		var full := "phase " + sub
		LimboConsole.print_line("%-20s%s" % [full, LimboConsole.get_command_description(full)])


func _phase_next(count: int = 1, wait_interval: float = 1.0) -> void:
	if not check_client("next"):
		return

	for i in count:
		if i:
			await Anim.sleep(wait_interval)
		Phase.manager.next_phase_or_turn()


func _phase_list() -> void:
	LimboConsole.print_line("\n".join(Phase.manager.phases.keys()))


func _phase_goto(target_phase: String, wait_interval := 0) -> void:
	if not check_client("goto"):
		return

	target_phase = get_name_match(target_phase, Phase.manager.phases.keys())
	if not target_phase:
		Anim.pop_up("bad phase name")
		return
	if wait_interval <= 0:
		Phase.manager.enter_phase_by_name(target_phase)
		Game.instance.enter_turn.rpc()
		return
	while true:
		if Phase.manager.get_phase().name == target_phase:
			break
		Phase.manager.next_phase_or_turn()
		await Anim.sleep(wait_interval)


#-----------------------------------------------------------------#
func check_client(subcommand := "") -> bool:
	if Network.is_server():
		return true

	LimboConsole.warn("phase " + subcommand + " command is not available on client side")
	return false


static func get_name_match(to_match: String, list: PackedStringArray) -> String:
	var candidate := ""
	for option in list:
		if option.to_lower().begins_with(to_match.to_lower()):
			if candidate:
				return ""
			candidate = option
	return candidate
