class_name Command
extends Node

var _commands: PackedStringArray = []


# add command, automatically manage the life cycle, prefer using this function
func _add_command(callable: Callable, command_name: StringName, description: String) -> void:
	LimboConsole.register_command(callable, command_name, description)
	_commands.append(command_name)


func _exit_tree() -> void:
	for i in _commands:
		LimboConsole.unregister_command(i)


#-----------------------------------------------------------------#
static func get_name_match(to_match: String, list: PackedStringArray) -> String:
	var candidate := ""
	for option in list:
		if option.to_lower().begins_with(to_match.to_lower()):
			if candidate:
				return ""
			candidate = option
	return candidate


func _print_commands():
	for sub: String in _commands:
		LimboConsole.print_line("%-20s%s" % [sub, LimboConsole.get_command_description(sub)])
