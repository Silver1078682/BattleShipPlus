@warning_ignore("missing_tool")
class_name ScopeMarkerProperty
extends ScopeMarkerArea

@export var property_index := "config:motility"
@export var exposure_punishment: int


func get_area() -> Area:
	if not action is ActionOperation:
		return area
	if area is AreaHex or area is AreaRing:
		var value = action.ship.get_indexed(property_index)
		if value is not int:
			Log.error("ScopeMarkerProperty should use a property of type int, but using ", property_index)
			return area
		area.radius = value
		if action.ship.is_exposed():
			area.radius -= exposure_punishment
	else:
		Log.warning("ScopeMarkerProperty using an area that is neither AreaHex nor AreaRing")
	return area
