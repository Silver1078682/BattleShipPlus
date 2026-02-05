extends Camera2D

func _ready() -> void:
	var map: Map = get_parent()
	position = map.sea.map_to_local(map.get_map_center())
	_print()


const BASE_SCALE = 100


func _print():
	var map: Map = get_parent()
	var size = map.get_map_size()
	var max_axis_value = size[size.max_axis_index()]
	zoom = BASE_SCALE * Vector2.ONE / max_axis_value / Map.TILE_SIZE
