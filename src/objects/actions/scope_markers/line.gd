@tool
class_name ScopeMarkerLine
extends ScopeMarkerArea

func _init() -> void:
	area = AreaLine.new()


func _mark_map_layer(_map_layer: MapLayer) -> void:
	if not area is AreaLine:
		Log.warning("the Area of a ScopeMarkerLine is not type of AreaLine")
		return
	area.start = Cursor.coord
	area.end = offset
	_map_layer.set_area(area)


func should_update_on_cursor_changed():
	return true


func _to_string() -> String:
	return "<ScopeMarkerLine>"
