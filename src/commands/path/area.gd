extends Command

func _enter_tree() -> void:
	_add_command(_area, "area", "Operation on an area")
	LimboConsole.add_argument_autocomplete_source("area", 0, func(): return AREA_TYPE)


const AREA_TYPE := ["home", "public", "base", "circle", "line", "rect"]


func _area(type: String, subcommand: String):
	var coords: Array[Vector2i]
	type = get_name_match(type, AREA_TYPE)

	var split := subcommand.split("--")
	var args: String
	match split.size():
		2:
			args = split[0]
			subcommand = split[1]
		1:
			pass
		_:
			LimboConsole.warn('bad subcommand format, should be "(args --) subcommand"')
			return

	match type:
		"home":
			coords = Map.instance.get_scope_home().keys()
		"public":
			coords = Map.instance.get_scope_public().keys()
		"base":
			coords = [Map.instance.get_base().coord]
		"circle":
			coords = parse_arg(AreaHex.new(), args)
		"line":
			coords = parse_arg(AreaLine.new(), args)
		"rect":
			coords = parse_arg(AreaRect.new(), args)
		_:
			return

	for coord in coords:
		LimboConsole.execute_command(subcommand.replace("$", str(coord)), true)


func parse_arg(base: Area, args: String) -> Array:
	for arg in args.split(" "):
		var pair := arg.split("=")
		if pair.size() != 2:
			LimboConsole.warn("bad arg format: %s" % arg)
			continue

		var key = parse_key(pair[0])
		var value = parse_value(pair[1])

		base.set(key, value)
	return base.get_coords().keys()

#-----------------------------------------------------------------#
const ARG_REMAP = {
	"a": "offset",
	"r": "radius",
}


func parse_key(key: String) -> String:
	key = key.strip_edges()
	key = ARG_REMAP.get(key, key)
	return key

#-----------------------------------------------------------------#
static var _value_remap: Dictionary[String, Callable] = {
	"(base)": func(): return Map.instance.get_base().coord,
	"(center)": func(): return Map.instance.get_map_center(),
}


func parse_value(a: String) -> Variant:
	if a in _value_remap:
		return _value_remap[a].call()
	if a.begins_with('(') and a.ends_with(')'):
		var vector = LimboConsole._parse_vector_arg(a)
		return vector
	return str_to_var(a)
