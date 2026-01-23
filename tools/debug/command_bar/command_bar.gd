extends HBoxContainer
## A command bar used to inject code runtime

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

	if command_edit.text.begins_with("$"):
		var text := command_edit.text.right(-1)
		if text == ">":
			Phase.manager.next_phase_or_turn()
			return

		var candicate := ""
		for phase_name in Phase.manager.phases:
			if phase_name.to_lower().begins_with(text):
				if candicate:
					Anim.pop_up("bad phase name")
					return
				candicate = phase_name

		if not candicate:
			Anim.pop_up("bad phase name")
			return

		Phase.manager.enter_phase_by_name(candicate)
		Game.instance.enter_turn.rpc()
		return

	if command_edit.text.begins_with("/"):
		var tester_name := command_edit.text.right(-1)
		var tester: Tester = Game.instance.get_node("Tests").get_node(tester_name)
		tester.run()
		return

	var script := GDScript.new()
	script.source_code = SCRIPT_TEMPLATE % command_edit.text
	script.reload()
	var instance = RefCounted.new()
	instance.set_script(script)

	if instance.has_method("run"):
		instance.run()
	else:
		print(instance.get_script().source_code)


func _on_button_pressed() -> void:
	run_command()
