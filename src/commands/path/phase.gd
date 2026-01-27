extends Command

func _enter_tree() -> void:
	_add_command(_phase, "phase", "phase management")
	_add_command(_phase_next, "phase next", "go to next phase")
	_add_command(_phase_list, "phase ls", "list all phases")
	_add_command(_phase_goto, "phase goto", "Go to certain phase")
	LimboConsole.add_argument_autocomplete_source("phase goto", 0, func(): return Phase.manager.phases.keys())


#-----------------------------------------------------------------#
func _phase() -> void:
	_print_commands()


func _phase_next(count: int = 1, wait_interval: float = 1.0) -> void:
	if not check_client("next"):
		return

	for i in count:
		if i:
			await Anim.sleep(wait_interval)
		Phase.manager.next_phase_or_turn()


func _phase_list() -> void:
	LimboConsole.print_line("\n".join(Phase.manager.phases.keys()))


func _phase_goto(target_phase: String, wait_interval := 0.0) -> void:
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
