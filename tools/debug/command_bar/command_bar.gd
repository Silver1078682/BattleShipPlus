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

	if command.begins_with("/"):
		_parse_tester(command.right(-1))
		return

	if OS.has_feature("template"):
		## Only permit injecting code when running in the editor
		return

	_inject_script(command)


func _on_button_pressed() -> void:
	run_command()


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
