class_name Map
extends Node2D
## Game map

## Node pointer
@onready var scope: Scope = $Area
@onready var aerial_defense_scope: Scope = $AerialDefenseScope
@onready var attack_scope: Scope = $AttackScope
@onready var sea: Sea = %Sea
@onready var base_manager: BaseManager = $Base

@export_group("map_meta")
@export var map_name: String

@export_group("map_layout")
@export var auto_map_center: bool
var _map_center: Vector2i
@export var map_center: Vector2i

const TILE_SIZE = 128

#-----------------------------------------------------------------#
var _map_center_calculated := false


func get_map_center() -> Vector2i:
	if not auto_map_center:
		return map_center
	if _map_center_calculated:
		return _map_center
	if get_coords().is_empty():
		_map_center_calculated = true
		return Vector2i.ZERO
	_map_center = _coord_reducer(func(a, b): return (a + b), Vector2i.ZERO) / get_coords().size()
	_map_center_calculated = true
	return _map_center

#-----------------------------------------------------------------#

var _map_size_calculated := false
var _map_size: Vector2i


func get_map_size() -> Vector2i:
	if _map_size_calculated:
		return _map_size
	var _left_top = _coord_reducer(func(a: Vector2i, b: Vector2i): return a.min(b), Vector2i.ZERO)
	var _right_bottom = _coord_reducer(func(a: Vector2i, b: Vector2i): return a.max(b), Vector2i.ZERO)
	_map_size = _right_bottom - _left_top
	_map_size_calculated = true
	return _map_size


func _coord_reducer(method: Callable, accum) -> Variant:
	return get_coords().keys().reduce(method, accum)


#-----------------------------------------------------------------#
## Get all coordinates in the map
func get_coords() -> Dictionary[Vector2i, int]:
	return sea.get_coords()


## Returns whether the coord is in map.
func has_coord(coord: Vector2i) -> bool:
	return coord in get_coords()


#-----------------------------------------------------------------#
# mark the home area
func get_scope_home() -> Dictionary[Vector2i, int]:
	return get_base().area.get_coords()

# mark the public area
var _public_cache: Dictionary[Vector2i, int]


func get_scope_public() -> Dictionary[Vector2i, int]:
	if not _public_cache:
		_public_cache = get_coords()
		for base: Base in base_manager.get_bases():
			for coord in base.area.get_coords():
				_public_cache.erase(coord)
	return _public_cache


## Returns the base of player with given player_id
## Returns the base of local player bt default
func get_base(player_id := Player.id) -> Base:
	var result := base_manager.get_base(player_id)
	if not result:
		Log.warning("Can not get the base for Player %s" % player_id)
	return result


#-----------------------------------------------------------------#
## Map a coordinate to position
static func coord_to_pos(coord: Vector2i) -> Vector2:
	return instance.sea.map_to_local(coord)


## Map a position to coordinate
static func pos_to_coord(pos: Vector2) -> Vector2i:
	return instance.sea.local_to_map(pos)

#-----------------------------------------------------------------#
static var instance: Map


func setup() -> void:
	_setup()


func _setup() -> void:
	var bases := base_manager.get_bases()
	for base in bases:
		base.setup()
