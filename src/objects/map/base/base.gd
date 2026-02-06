@tool
class_name Base
extends TileMapLayer
## The base of the game

@onready var sprite: Sprite2D = $Sprite

@export var coord := Vector2i.ZERO:
	set(p_coord):
		if is_node_ready():
			_set_coord(p_coord)
		coord = p_coord

#-----------------------------------------------------------------#
var _coords: Dictionary[Vector2i, int]


func _init_coords() -> void:
	for i in get_used_cells():
		_coords[i + coord] = 0


func get_coords() -> Dictionary[Vector2i, int]:
	Log.debug(name, _coords)
	return _coords


#-----------------------------------------------------------------#
func setup() -> void:
	_setup()


func _setup() -> void:
	for i in get_children():
		if i.has_method("setup"):
			i.setup()


func _ready() -> void:
	await NodeUtil.ensure_ready(get_map())
	self_modulate = Color(0, 0, 0, 0)
	_init_coords()
	_set_coord(coord)


func _set_coord(p_coord: Vector2i) -> void:
	var sea: Sea = get_map().get_node(^"%Sea")
	position = sea.map_to_local(p_coord) - sea.map_to_local(Vector2i.ZERO)


func get_map() -> Map:
	return NodeUtil.find_first_ancestor_matching_condition(self, func(node): return node is Map)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		var sea: Sea = get_map().get_node(^"%Sea")
		coord = sea.local_to_map(position + sea.map_to_local(Vector2i.ZERO))
