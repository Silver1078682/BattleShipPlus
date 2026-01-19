class_name ActionAerialDefense
extends ActionOperation

#-----------------------------------------------------------------#
@export_group("aerial_defense")
@export var aerial_defense_area: Area
@export var aerial_defense_follow_mouse: bool

#-----------------------------------------------------------------#
# TODO TBD it's weird putting this code here, but not in Area class
static var _aerial_defense_areas: Dictionary[Vector2i, Area]
static var _aerial_defense_coords: Dictionary[Vector2i, int]


## Add an aerial defense area
## note that all *_aerial_defense_area does not update the Map.instance.aerial_defense_scope immediately
static func add_aerial_defense_area(area: Area) -> void:
	_aerial_defense_areas[area.offset] = area
	for coord: Vector2i in area.get_coords():
		_aerial_defense_coords[coord] = _aerial_defense_coords.get_or_add(coord, 0) + 1


static func get_aerial_defense_areas() -> Dictionary[Vector2i, Area]:
	return _aerial_defense_areas


static func clear_aerial_defense_areas() -> void:
	_aerial_defense_areas.clear()
	_aerial_defense_coords.clear()


static func delete_aerial_defense_area_at(offset: Vector2i) -> void:
	if offset not in _aerial_defense_areas:
		return
	var area = _aerial_defense_areas[offset]
	for coord: Vector2i in area.get_coords():
		if coord not in _aerial_defense_coords:
			continue

		_aerial_defense_coords[coord] -= 1
		if _aerial_defense_coords[coord] == 0:
			_aerial_defense_coords.erase(coord)


static func update_map() -> void:
	Game.instance.map.aerial_defense_scope.set_dict(_aerial_defense_coords)


#-----------------------------------------------------------------#
func _committed() -> bool:
	var coord := Cursor.coord if follow_mouse else _ship.coord
	add_aerial_defense_area(aerial_defense_area)
	return defend_at(coord)


func _reverted() -> bool:
	delete_aerial_defense_area_at(_last_aerial_defense_position)
	update_map()
	return true


func _cancelled() -> void:
	super()
	update_map()


#-----------------------------------------------------------------#
func _update_cursor(_p_coord: Vector2i, _cursor: Cursor) -> void:
	var coord = _last_aerial_defense_position if has_committed() else Cursor.coord
	aerial_defense_area.offset = coord
	update_map()
	Game.instance.map.aerial_defense_scope.set_area(aerial_defense_area, true, Scope.OperationMode.ADD)

#-----------------------------------------------------------------#
var _last_aerial_defense_position: Vector2i


func defend_at(coord: Vector2i) -> bool:
	_last_aerial_defense_position = coord
	return true


func _get_defense_coords(coord: Vector2i) -> Dictionary[Vector2i, int]:
	if not aerial_defense_area:
		Log.warning("The aerial_defense area is not assigned")
		return { }

	var results: Dictionary[Vector2i, int]
	aerial_defense_area.offset = coord
	return results


#-----------------------------------------------------------------#
func _to_string() -> String:
	return "{%s | Ship: %s | Area: %s}" % [resource_name, _ship, aerial_defense_area]
