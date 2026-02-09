@tool
class_name ScopeMarkerRange
extends ScopeMarkerArea

func _mark_map_layer(_map_layer: MapLayer) -> void:
	area.offset = Cursor.coord if follow_cursor else offset
	area.radius = HexGrid.distance(Cursor.coord, offset)
	_map_layer.set_area(area)


func should_update_on_cursor_changed():
	return true


func _to_string() -> String:
	return "<ScopeMarkerRange>"
