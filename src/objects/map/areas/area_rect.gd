@tool
class_name AreaRect
extends Area

## Size of the rectangles
@export var size: Vector2i:
	set(p_size):
		if size != p_size:
			size = p_size
			request_update()

## This will make the result look as if it is 0.5 grids thinner
@export var shrink_edge: bool:
	set(p_shrink_edge):
		if shrink_edge != p_shrink_edge:
			shrink_edge = p_shrink_edge
			request_update()


func _get_shape() -> Dictionary[Vector2i, int]:
	var results: Dictionary[Vector2i, int]
	for y in range(0, size.y, sign(size.y)):
		@warning_ignore("integer_division")
		var start_x = -y / 2
		var size_x = size.x - (1 if shrink_edge and y % 2 else 0)
		for x in range(start_x, start_x + size_x, sign(size.x)):
			results[Vector2i(x, y)] = 0
	return results


func _to_string() -> String:
	return "[RECT %s @%s]" % [size, offset]
