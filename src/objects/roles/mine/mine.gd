class_name Mine
extends Node2D

const DAMAGE = 5

var coord: Vector2i:
	set(p_coord):
		position = Map.coord_to_pos(p_coord)
		coord = p_coord


func _to_string() -> String:
	return "Mine @%s" % coord
