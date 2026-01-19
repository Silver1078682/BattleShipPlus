class_name CmdLineInterface
extends RefCounted

static var network: PackedStringArray = []
static var log_level: PackedStringArray = []


static func add_unique_arg_to(arr: PackedStringArray, value: Variant) -> void:
	if arr:
		Log.warning("duplicate arr_name args")
	arr.append(value)


static func parse(args: PackedStringArray) -> void:
	var last_arg := ""
	for arg in args:
		if last_arg == "client":
			network.append(arg)
		elif arg in ["host", "client"]:
			add_unique_arg_to(network, arg)
		elif arg in ["debug", "info", "warning", "error"]:
			add_unique_arg_to(log_level, arg)
		last_arg = arg

	if log_level:
		Log.log_level = Log.Level.get(log_level[0].to_upper())
	Log.debug("CLI args:", args)

	await Main.instance.ready
	if network:
		if network[0] == "host":
			Network.instance.start_server()
		elif network[0] == "client":
			if network.size() >= 2:
				Network.instance.start_client(network[1])
			else:
				Network.instance.start_client("localhost")
