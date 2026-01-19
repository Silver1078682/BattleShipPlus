class_name Base
extends Node2D

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
	await NodeUtil.ensure_ready(Map.instance)
	position = Map.coord_to_pos(coord)
