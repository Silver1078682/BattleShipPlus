class_name Map
extends Node2D

## Node pointer
@onready var scope: Scope = $Area
@onready var aerial_defense_scope: Scope = $AerialDefenseScope
@onready var attack_scope: Scope = $AttackScope
@onready var sea: Sea = $Sea
@onready var base_manager: BaseManager = $Base

## Map layout
@export var map_area: Area
@export var _map_center: Vector2i
#@export var WIDTH = 30
#@export var HEIGHT = 15

const TILE_SIZE = 128


#-----------------------------------------------------------------#
func get_map_center() -> Vector2:
	return _map_center


## Get all coordinates in the map
func get_coords() -> Dictionary[Vector2i, int]:
	return map_area.get_coords()


## Returns whether the coord is in map.
func has_coord(coord: Vector2i) -> bool:
	return map_area.has_point(coord)


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


func _init() -> void:
	assert(not instance, "singleton instance initialized")
	instance = self
