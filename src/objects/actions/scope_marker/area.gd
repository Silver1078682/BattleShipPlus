@tool
class_name ScopeMarkerArea
extends ScopeMarker

@export var follow_cursor := false
@export var area: Area:
	get = get_area


func get_area() -> Area:
	return area


func should_update_on_cursor_changed():
	return follow_cursor


func mark_map_layer(_map_layer: MapLayer, coord: Vector2i) -> void:
	area.offset = Cursor.coord if follow_cursor else coord
	_map_layer.set_area(area)


func unmark_map_layer(_map_layer: MapLayer) -> void:
	_map_layer.clear_mask()


func get_coords() -> void:
	return area.get_coords()


func rotate(times: int) -> void:
	area.rotate(times)


# QOL improvement
func _validate_property(_property: Dictionary) -> void:
	resource_name = str(self)


func _to_string() -> String:
	return "ScopeMK< %s %d >" % [area, map_layer]
