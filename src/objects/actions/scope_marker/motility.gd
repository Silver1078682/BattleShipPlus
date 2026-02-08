@tool
class_name ScopeMarkerMotility
extends ScopeMarkerArea

@export var exposure_punishment: int


func get_area() -> Area:
	if action is ActionOperation:
		if area is AreaHex or area is AreaRing:
			area.radius = action.ship.config.motility
			area.radius -= exposure_punishment
	return area
