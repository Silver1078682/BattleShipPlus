@tool
class_name AreaRing
extends Area

# CREDIT: https://www.redblobgames.com/grids/hexagons/

@export_range(0, 60) var radius: int:
	set(p_radius):
		radius = p_radius
		request_update()


func _get_shape() -> Dictionary[Vector2i, int]:
	const DIRE_COUNT = 6
	var results: Dictionary[Vector2i, int]
	var coord := Vector2i(1, 0) * radius
	for dire_idx in DIRE_COUNT:
		for i in radius:
			results[coord] = 0
			coord += RING[dire_idx]
	return results


const RING: Array[Vector2i] = [
	Vector2i(0, -1),
	Vector2i(-1, 0),
	Vector2i(-1, 1),
	Vector2i(0, 1),
	Vector2i(1, 0),
	Vector2i(1, -1),
]


func _to_string() -> String:
	return "[RING %s @%s]" % [radius, offset]
