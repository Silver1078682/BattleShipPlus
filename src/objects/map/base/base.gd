class_name Base
extends Node2D
## The base of the game

@onready var sprite: Sprite2D = $Sprite

@export var coord := Vector2i.ZERO

@export var area: Area:
	get:
		if Engine.is_editor_hint():
			return area
		if area.offset != coord:
			area.offset = coord
		return area


func _ready() -> void:
	await NodeUtil.ensure_ready(get_map())
	position = get_map().sea.map_to_local(coord)


func get_map() -> Map:
	return NodeUtil.find_first_ancestor_matching_condition(self, func(node): return node is Map)
