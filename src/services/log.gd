class_name Log
extends Node

#-----------------------------------------------------------------#
static func _static_init() -> void:
	log_file = FileUtil.open_file("user://logs/%s" % Time.get_datetime_string_from_system(), FileAccess.WRITE)
	info("Log service start, writing to file " + ProjectSettings.globalize_path("user://logs/%s" % Time.get_datetime_string_from_system()))


static var log_file: FileAccess

#-----------------------------------------------------------------#
static var log_level := Level.INFO
static var stack_trace_level := Level.WARNING
static var debug_pop_up := true


static func error(...variant) -> void:
	if log_level >= Level.ERROR:
		var string := _arr_to_str(variant)
		push_error(string)
		if debug_pop_up and Anim.instance:
			Anim.pop_up(string)
		_print(Level.ERROR, "red", "[ERROR]", string)


static func warning(...variant) -> void:
	if log_level >= Level.WARNING:
		var string := _arr_to_str(variant)
		push_warning(string)
		_print(Level.WARNING, "yellow", "[WARNING]", string)


static func info(...variant) -> void:
	if log_level >= Level.INFO:
		var string := _arr_to_str(variant)
		_print(Level.INFO, "", "[INFO]", string)


static func debug(...variant) -> void:
	if log_level >= Level.DEBUG:
		var string := _arr_to_str(variant)
		_print(Level.DEBUG, "darkgray", "[DEBUG]", string)


enum Level {
	ERROR,
	WARNING,
	INFO,
	DEBUG,
}


#-----------------------------------------------------------------#
static func _arr_to_str(arr: Array) -> String:
	return arr.map(func(x): return str(x)).reduce(func(x, y): return x + y, "")


static func _print(level: Level, color: String, prefix: String, message: String) -> void:
	var time := Time.get_datetime_string_from_system()
	var network := str(Network.instance)
	var info_string := "%-10s %s %-10s" % [prefix, time, network]
	var string: String = info_string + message
	if log_file:
		log_file.store_line(string)
	print_rich("[color=", color, "]", string, "[/color]")
	_print_stack(level)


static func _print_stack(level: Log.Level) -> void:
	if stack_trace_level >= level:
		for stack_info in get_stack().slice(3):
			print_rich("[color=darkgray]- {source}:{line} \t\t#{function}[/color]".format(stack_info))
		print("\n")
