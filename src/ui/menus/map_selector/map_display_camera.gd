extends Camera2D

func _ready() -> void:
	var map: Map = get_parent()
	# adjust pos
	position = map.sea.map_to_local(map.get_map_center())
	# adjust zoom
	var size = map.get_map_rect().size
	var max_axis_value = size[size.max_axis_index()]
	var p_zoom = BASE_SCALE * Vector2.ONE / max_axis_value / Map.TILE_SIZE
	if p_zoom.x and p_zoom.y:
		zoom = p_zoom
	else:
		return


const BASE_SCALE = 100
