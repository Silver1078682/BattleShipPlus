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


func start(p_action: Action, _coord: Vector2i) -> void:
	super(p_action, _coord)
	if not area:
		Log.warning("ScopeMarkerArea starts, but with no area set")


func _mark_map_layer(_map_layer: MapLayer) -> void:
	area.offset = Cursor.coord if follow_cursor else offset
	_map_layer.set_area(area)


func _unmark_map_layer(_map_layer: MapLayer) -> void:
	_map_layer.clear_mask()


func get_coords() -> Dictionary[Vector2i, int]:
	return area.get_coords()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("rotate_forward"):
		area.rotate(1)
		mark()
	if event.is_action_pressed("rotate_backward"):
		area.rotate(-1)
		mark()


func rotate(times: int) -> void:
	area.rotate(times)


# QOL improvement
func _validate_property(_property: Dictionary) -> void:
	resource_name = str(self)


func _to_string() -> String:
	return "ScopeMK< %s %d >" % [area, map_layer]
