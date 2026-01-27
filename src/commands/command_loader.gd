extends Node

const PATH := "res://src/commands/path/"


func _ready() -> void:
	if not OS.is_debug_build():
		return

	var dir_access := FileUtil.open_dir(PATH)
	for command_file_name in dir_access.get_files():
		if not command_file_name.ends_with(".gd"):
			continue
		var command_file: GDScript = load(PATH + command_file_name)
		var command_node = command_file.new()
		add_child(command_node)
