@tool
class_name PhaseActionGroup
extends Resource

@export var start: Array[Action] = []
@export var course: Array[Action] = []
@export var end: Array[Action] = []


# QOL improvement
func _validate_property(_property: Dictionary) -> void:
	if (start.size() + course.size() + end.size()) <= 1:
		if start.size():
			resource_name = "<S:%s>" % [start[0].action_name]
		elif course.size():
			resource_name = "<C:%s>" % [course[0].action_name]
		elif end.size():
			resource_name = "<E:%s>" % [end[0].action_name]
		else:
			resource_name = "<Empty>"

	else:
		resource_name = "<S%d C%d E%d>" % [start.size(), course.size(), end.size()]
