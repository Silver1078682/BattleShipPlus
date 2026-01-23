class_name Scope
extends TileMapLayer
## A highlighted area indicating the scope or area of action

@export var default_operation_mode: OperationMode
enum OperationMode {
	SET, ## Set the area to this value.
	ADD, ## The union of the existing area and this value.
	ERASE, ## The subtraction of this value from the existing area.
}


#-----------------------------------------------------------------#
## Set the Scope to a specific area
func set_area(area: Area, clamped := true, operation := OperationMode.SET) -> void:
	set_dict(area.get_coords(), clamped, operation)


## Set the Scope to a hash set(Dictionary) of coordinates
func set_dict(coords: Dictionary[Vector2i, int], clamped := true, operation := OperationMode.SET) -> void:
	match operation:
		OperationMode.SET:
			_coords = coords
		OperationMode.ADD:
			_coords.merged(coords)
		OperationMode.ERASE:
			coords.keys().map(func(coord: Vector2i): _coords.erase(coord))

	if operation == OperationMode.SET:
		clear()
	for coord in coords:
		if clamped and not (coord) in Game.instance.map.get_coords():
			continue
		if operation == OperationMode.ERASE:
			_erase_tile(coord)
		else:
			_set_tile(coord)


#-----------------------------------------------------------------#
func has_coord(coord: Vector2i) -> bool:
	return (coord) in _coords


func clear_mask() -> void:
	_coords = { }
	self.clear()

#-----------------------------------------------------------------#
var _coords: Dictionary[Vector2i, int]


func get_coords() -> Dictionary[Vector2i, int]:
	return _coords


#-----------------------------------------------------------------#
# wrapper for setting a tile
func _set_tile(coords: Vector2i, source_id := 0, atlas_coords := Vector2i.ZERO, alternative_tile: int = 0) -> void:
	set_cell(coords, source_id, atlas_coords, alternative_tile)


# wrapper for erasing a tile
func _erase_tile(coords: Vector2i) -> void:
	erase_cell(coords)
