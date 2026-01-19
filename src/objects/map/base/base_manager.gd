class_name BaseManager
extends Node2D

@export var home_color: Color
@export var enemy_color: Color


#-----------------------------------------------------------------#
func _ready() -> void:
	for idx in get_base_count():
		var base := get_base(idx)
		base.sprite.modulate = home_color if idx == Player.id else enemy_color


#-----------------------------------------------------------------#
func get_base(idx: int) -> Base:
	if idx >= get_child_count():
		return null
	var base := get_child(idx)
	assert(base is Base)
	return base


func get_bases() -> Array[Base]:
	var bases: Array[Base] = []
	bases.assign(get_children())
	return bases


func get_base_count() -> int:
	return get_child_count()
