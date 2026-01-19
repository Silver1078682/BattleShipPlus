@tool
@abstract class_name Area
extends Resource

var offset: Vector2i


#-----------------------------------------------------------------#
## Get the coord represented by the shape, the offset is respected in this method.
func get_coords() -> Dictionary[Vector2i, int]:
	var results: Dictionary[Vector2i, int]
	for coord in get_shape():
		results[coord + offset] = 0
	return results


## Get the coord of the shape, the offset is ignored. Also see [method get_coords]
## To implement a new shape, please override [method _get_shape]
func get_shape() -> Dictionary[Vector2i, int]:
	if _shape_need_updating:
		_shape_need_updating = false
		update_shape()
	return _shape_cache


## This virtual function should return a list of the coords representing the shape
## The result should be hashed and will be chached for future reuse.
@abstract func _get_shape() -> Dictionary[Vector2i, int]


#-----------------------------------------------------------------#
## Return if a coord is in the area
func has_point(point: Vector2i) -> bool:
	return _is_in_shape(point - offset)


## This virtual function should return if a point is in the shape, offset ignored
func _is_in_shape(at: Vector2i) -> bool:
	return at in _shape_cache


#-----------------------------------------------------------------#
## Rotate the shape to (0, 0) with (times * PI /3) degrees,
## please override the [method _rotate] to impolement a rotation
func rotate(times: int) -> void:
	_rotate(posmod(times, 6))


func _rotate(_times: int) -> void:
	pass




#-----------------------------------------------------------------#
var _shape_need_updating := true
var _shape_cache: Dictionary[Vector2i, int]


## request an update for the shape of this area
## call this function only when it is neccessary
## e.g the radius grows by 2, or an asymmetric shape is mirrored
## Please note that the shape won't be actually updated
## until the [method get_shape] or [method get_coord] is called.
func request_update() -> void:
	_shape_need_updating = true


func update_shape() -> void:
	_shape_cache = _get_shape()
