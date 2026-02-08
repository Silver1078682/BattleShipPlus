@tool
class_name ScopeMarkerArea
extends ScopeMarker

@export var area: Area
@export var follow_cursor := false


func should_update_on_cursor_changed():
	return follow_cursor


func mark_scope(_scope: Scope, coord: Vector2i) -> void:
	area.offset = Cursor.coord if follow_cursor else coord
	_scope.set_area(area)


func unmark_scope(_scope: Scope) -> void:
	_scope.clear_mask()


func get_coords() -> void:
	return area.get_coords()


# QOL improvement
func _validate_property(_property: Dictionary) -> void:
	resource_name = str(self)


func _to_string() -> String:
	return "ScpM< %s %d >" % [area, scope_layer]
