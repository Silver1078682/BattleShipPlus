@tool
extends EditorScript

var _buffer: String
var _indent = 0
const INDENT_UNIT = "\t"


func indent(count := 1):
	_indent += count


func write(...args):
	if _buffer:
		_buffer += "\t"
	else:
		_buffer = INDENT_UNIT.repeat(_indent)
	_buffer += str.callv(args)


func write_tab(...args):
	if _buffer:
		_buffer += "\t"
	else:
		_buffer = INDENT_UNIT.repeat(_indent)
	_buffer += "%-16s" % str.callv(args)


func flush():
	print(_buffer)
	_buffer = ""


const PROPERTIES: Dictionary[String, String] = {
	"prop\\name" ="{name}({abbreviation})",
	Health = "{health}",
	Motility = "{motility}",
	Torpedo = "CAP:{torpedo}",
	Aerial = "DEFENSE:{aerial_defense}",
	Artillery = "RAN:{artillery_distance} LVL:{artillery_level}",
	Arrange = "COST:{cost} LIMIT:{arrange_limit}",
}


func print_prop_table(res_folder: Array[Resource]):
	for row_name in PROPERTIES:
		write_tab(row_name)
		var expression_string := PROPERTIES[row_name]
		for res in res_folder:
			write_tab(expression_string.format(res))
		flush()

#
#func print_phase_table(warship_cfgs: Array[Resource]):
#for phase in ResourceUtil.load_directory("phases"):
#for cfg: WarshipConfig in warship_cfgs:
#var action_group: PhaseActionGroup = cfg.action_groups.get(phase.name, null)
#for i in action_group:
#pass
#if action_group.start:
#pass


func print_action_table(warship_cfgs: Array[Resource]):
	for cfg: WarshipConfig in warship_cfgs:
		write(cfg.name)
		flush()

		indent()
		for phase in ResourceUtil.load_directory("phases"):
			var action_group: PhaseActionGroup = cfg.action_groups.get(phase.name, null)
			if not action_group:
				continue
			write("-", phase.name)
			flush()

			indent()
			for period_id in ["start", "course", "end"]:
				var actions: Array[Action] = action_group.get(period_id)
				if not actions:
					continue
				for action in actions:
					write("-", period_id[0].capitalize(), ":", action.action_name)
					flush()
			indent(-1)

		indent(-1)


func _run() -> void:
	var warship_cfgs: Array[Resource] = ResourceUtil.load_directory("warships")
	print_prop_table(warship_cfgs)
	print_action_table(warship_cfgs)
