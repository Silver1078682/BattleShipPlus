extends HBoxContainer
## A command bar

@onready var command_edit: LineEdit = $CommandEdit
@onready var button: Button = $Button

const SCRIPT_TEMPLATE = """
extends RefCounted
func s(name: String, value) -> void:
	Game.instance.set_meta(name, value)

func g(name: String) -> Variant:
	return Game.instance.get_meta(name)


func run():
\t%s
\tpass
"""


func run_command():
	if not OS.is_debug_build():
		return

	var command := command_edit.text
	if command.begins_with("$"):
		_parse_phase_jumper(command.right(-1))
		return

	if command.begins_with("/"):
		_parse_tester(command.right(-1))
		return

	if OS.has_feature("template"):
		## Only permit injecting code when running in the editor
		return

	_inject_script(command)


func _on_button_pressed() -> void:
	run_command()


func _shortcut_input(_event: InputEvent) -> void:
	# Accept event while editing the command
	if command_edit.is_editing():
		accept_event()


#-----------------------------------------------------------------#
func _parse_phase_jumper(command: String):
	if not Network.is_server():
		return

	if command.begins_with(">"):
		command = command.right(-1)

		var split_command := command.split(",")
		var target_string := split_command.get(0)
		if target_string == "":
			# $>
			# Goto next phase
			Phase.manager.next_phase_or_turn()
			return

		var wait_interval := 1.0
		var wait_interval_string := "" if split_command.size() < 2 else split_command[1]
		if wait_interval_string.is_valid_float():
			wait_interval = str_to_var(wait_interval_string)

		elif target_string.is_valid_int():
			# $>5
			# Jump to next phase for 5 times
			for i in str_to_var(target_string):
				await Anim.sleep(wait_interval)
			Phase.manager.next_phase_or_turn()
			return

		# $>PhaseName
		# Jump until reaching certain Phase
		var target_phase := get_name_match(target_string, Phase.manager.phases.keys())
		if not target_phase:
			Anim.pop_up("bad phase name")
			return
		while true:
			if Phase.manager.get_phase().name == target_phase:
				break
			Phase.manager.next_phase_or_turn()
			await Anim.sleep(wait_interval)

	# $PhaseName
	# Goto certain phase
	var phase_name := get_name_match(command, Phase.manager.phases.keys())
	if not phase_name:
		Anim.pop_up("bad phase name")
		return

	Phase.manager.enter_phase_by_name(phase_name)
	Game.instance.enter_turn.rpc()
	return


static func get_name_match(to_match: String, list: PackedStringArray) -> String:
	var candidate := ""
	for option in list:
		if option.to_lower().begins_with(to_match.to_lower()):
			if candidate:
				return ""
			candidate = option
	return candidate


#-----------------------------------------------------------------#
func _parse_tester(command: String):
	if not Game.instance:
		return
	var tester_manager := Game.instance.get_node("Tests")
	if command.to_lower() == "help":
		# print all available command
		print(",".join(tester_manager.get_children().map(func(node: Node): return node.name)))
		return
	var test: Tester = tester_manager.get_node(command)
	test.run()
	return


#-----------------------------------------------------------------#
# inject code runtime
func _inject_script(text: String):
	var script := GDScript.new()
	script.source_code = SCRIPT_TEMPLATE % text
	script.reload()
	var instance = RefCounted.new()
	instance.set_script(script)

	if instance.has_method("run"):
		instance.run()
	else:
		print(instance.get_script().source_code)
