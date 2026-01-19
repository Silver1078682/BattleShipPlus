@tool
class_name AreaHex
extends Area

# CREDIT: https://www.redblobgames.com/grids/hexagons/

@export_range(0, 60) var radius: int:
	set(p_radius):
		radius = p_radius
		request_update()

# A Hexadgon is just several Rings
static var _calculator := AreaRing.new()


func _get_shape() -> Dictionary[Vector2i, int]:
	var results: Dictionary[Vector2i, int] = { Vector2i.ZERO: 0 }
	for i in range(1, radius + 1):
		_calculator.radius = i
		var ring := _calculator.get_shape()
		results.merge(ring)
	return results


func _is_in_shape(at: Vector2i) -> bool:
	return super(at)


func _to_string() -> String:
	return "[HEX %s @%s]" % [radius, offset]
