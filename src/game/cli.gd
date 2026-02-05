class_name CmdLineInterface
extends RefCounted
## Handles command line arguments for the game.

#-----------------------------------------------------------------#
var options: Dictionary[String, String]
var flags: Dictionary[String, bool]
var arguments: PackedStringArray


func parse_args(args: PackedStringArray) -> void:
	for arg: String in args:
		if arg.begins_with("--"):
			# a flag or an option
			if "=" in arg:
				# an option with value, e.g., --option=value
				var parts := arg.split('=')
				var option_name := parts[0].right(-2)
				var option_value := parts[1]
				options[option_name] = option_value
			else:
				# a flag
				var flag_name = arg.right(-2)
				flags[flag_name] = true
		else:
			# a positional argument
			arguments.append(arg)


#-----------------------------------------------------------------#
func parse_and_apply(args: PackedStringArray) -> void:
	parse_args(args)
	apply_all()
	Log.debug("CLI args:", args)


func apply_all() -> void:
	_apply_options()
	_apply_flags()
	_apply_arguments()


#-----------------------------------------------------------------#
func _apply_options() -> void:
	for option in options:
		var value = options[option]
		match option:
			"log":
				Log.log_level = Log.Level.get(value.to_upper(), Log.Level.INFO)
			"host":
				_host(value)
			"join":
				_join(value)


func _apply_flags() -> void:
	if flags.has("host"):
		_host("Default")
	elif flags.has("join"):
		_join("localhost")


func _apply_arguments() -> void:
	pass


#-----------------------------------------------------------------#
func _host(map_name: String) -> void:
	await Main.instance.ready
	var map_scene: PackedScene = ResourceUtil.load_resource("maps", map_name, null, "tscn")
	if map_scene:
		Map.instance = map_scene.instantiate()
		Network.instance.start_server()


func _join(host_ip: String) -> void:
	await Main.instance.ready
	Network.instance.start_client(host_ip)
