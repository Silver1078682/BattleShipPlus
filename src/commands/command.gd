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
