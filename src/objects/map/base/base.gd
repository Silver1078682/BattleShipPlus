@tool
class_name Base
extends Node2D
## The base of the game

@onready var sprite: Sprite2D = $Sprite

@export var coord := Vector2i.ZERO:
	set(p_coord):
		if is_node_ready():
			_set_coord(p_coord)
		coord = p_coord

@export var area: Area:
	get:
		if Engine.is_editor_hint():
			return area
		if area.offset != coord:
			area.offset = coord
		return area


#-----------------------------------------------------------------#
func setup() -> void:
	_setup()


func _setup() -> void:
	for i in get_children():
		if i.has_method("setup"):
			i.setup()


func _ready() -> void:
	await NodeUtil.ensure_ready(get_map())
	_set_coord(coord)


func _set_coord(p_coord: Vector2i) -> void:
	position = get_map().get_node(^"%Sea").map_to_local(p_coord)


func get_map() -> Map:
	return NodeUtil.find_first_ancestor_matching_condition(self, func(node): return node is Map)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		coord = get_map().get_node(^"%Sea").local_to_map(position)
