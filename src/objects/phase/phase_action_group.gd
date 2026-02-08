@tool
class_name PhaseActionGroup
extends Resource

@export var start: Array[Action] = []:
	get:
		return arr_getter(start)
@export var course: Array[Action] = []:
	get:
		return arr_getter(course)
@export var end: Array[Action] = []:
	get:
		return arr_getter(end)


# QOL improvement
func _validate_property(_property: Dictionary) -> void:
	if (start.size() + course.size() + end.size()) <= 1:
		if is_valid_arr(start):
			resource_name = "<S:%s>" % [start[0].action_name]
		elif is_valid_arr(course):
			resource_name = "<C:%s>" % [course[0].action_name]
		elif is_valid_arr(end):
			resource_name = "<E:%s>" % [end[0].action_name]
		else:
			resource_name = "<EmptyActionGroup>"

	else:
		resource_name = "<S%d C%d E%d>" % [start.size(), course.size(), end.size()]


func is_valid_arr(arr) -> bool:
	return arr.size() and is_instance_valid(arr[0])


func arr_getter(arr: Array[Action]) -> Array[Action]:
	if Engine.is_editor_hint():
		return arr
	var result: Array[Action]
	result.assign(arr.map(func(act: Action): return act.duplicate(true)))
	return result
