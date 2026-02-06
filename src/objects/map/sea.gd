@tool
class_name Sea
extends Scope

@export_tool_button("Apply") var _editor_apply_area_button = _editor_apply_area
@export var area: Area
@export var _op_mode: OperationMode


func _editor_apply_area() -> void:
	print(area)
	set_area(area, false, _op_mode)


func _ready() -> void:
	for i in get_used_cells():
		_coords[i] = 0

# TEMP
var _track


func _process(_delta: float) -> void:
	if _track != _coords:
		print(Network.instance, self, "fucked, _coords", _coords)
	_track = _coords.duplicate()
