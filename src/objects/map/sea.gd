class_name Sea
extends TileMapLayer

const TILE_COORD = Vector2i.ZERO


func _ready() -> void:
	clear()
	for coord in Map.instance.get_coords():
		set_tile(coord)
	Log.debug("Map tiles drawn")


func set_tile(coords: Vector2i, source_id := 0, atlas_coords := TILE_COORD, alternative_tile: int = 0) -> void:
	set_cell(coords, source_id, atlas_coords, alternative_tile)
