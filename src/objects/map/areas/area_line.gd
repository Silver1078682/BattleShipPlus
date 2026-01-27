@tool
class_name AreaLine
extends Area
## Area representing a line.

@export var start: Vector2i:
	set(p_start):
		if start != p_start:
			start = p_start
			request_update()

@export var end: Vector2i:
	set(p_end):
		if end != p_end:
			end = p_end
			request_update()


func is_parallel_to_axis() -> bool:
	return HexGrid.is_parallel_to_axis(start - end)


func cube_linedraw(a: Vector2i, b: Vector2i) -> PackedVector3Array:
	var n = HexGrid.distance(a, b)
	var results: PackedVector3Array
	for i in range(n + 1):
		results.append(
			cube_round(
				lerp(
					Vector3(HexGrid.to_cubic(a)),
					Vector3(HexGrid.to_cubic(b)),
					1.0 / n * i,
				),
			),
		)

	return results


func cube_round(frac: Vector3) -> Vector3i:
	var x = round(frac.x)
	var y = round(frac.y)
	var z = round(frac.z)

	var x_diff = abs(x - frac.x)
	var y_diff = abs(y - frac.y)
	var z_diff = abs(z - frac.z)

	if x_diff > y_diff and x_diff > z_diff:
		x = -y - z
	elif y_diff > z_diff:
		y = -x - z
	else:
		z = -x - y

	return Vector3i(x, y, z)


## Rotate counter clockwise, and rotate (times * 60) degree
func _rotate(times: int) -> void:
	start = HexGrid.rotate_a_point(start, times)
	end = HexGrid.rotate_a_point(end, times)


func _get_shape() -> Dictionary[Vector2i, int]:
	if start == end:
		return { start: 0 }

	var result: Dictionary[Vector2i, int]
	for coord in cube_linedraw(start, end):
		result[Vector2i(coord.x, coord.y)] = 0
	return result


func _to_string() -> String:
	return "[LINE %s>%s @%s]" % [start, end, offset]
