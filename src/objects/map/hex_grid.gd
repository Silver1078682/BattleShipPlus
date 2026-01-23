class_name HexGrid
extends Object

## A function library for hexagonal grids.
# CREDIT: https://www.redblobgames.com/grids/hexagdons/

## Rotate a point to (0, 0) with (times * PI /6) degrees
static func rotate_a_point(point: Vector2i, times: int) -> Vector2i:
	var cubic := to_cubic(point)
	var sign_flip := -1 if (times % 2) else 1
	return sign_flip * Vector2i(cubic[posmod(times, 3)], cubic[posmod(times + 1, 3)])


#-----------------------------------------------------------------#
## Return the distance between two point
static func distance(a: Vector2i, b: Vector2i) -> int:
	var delta := a - b
	var cube_delta := to_cubic(delta)
	return (abs(cube_delta.x) + abs(cube_delta.y) + abs(cube_delta.z)) / 2


## Return a cubic coord form of a Vector2i
static func to_cubic(point: Vector2i) -> Vector3i:
	return Vector3i(point.x, point.y, -point.x - point.y)


static func is_parallel_to_axis(vector: Vector2i) -> bool:
	var cubic := HexGrid.to_cubic(vector)
	# one of the components should be zero and the vector itself is not zero
	return not (cubic.x and cubic.y and cubic.z) and cubic
