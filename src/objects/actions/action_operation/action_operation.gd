class_name ActionOperation
extends Action
## [Action]s that act as Behaviors of a Warship.

var ship: Warship:
	get:
		return _ship
	set(p_ship):
		assert(p_ship != null)
		_ship = p_ship

var _ship: Warship

## After the this action has reached commit limit, no other [ActionOperation]s of [member _ship] can be committed.
@export var is_terminating := false


func _get_map_layer_marker_default_coord():
	return _ship.coord


func commit() -> void:
	if not _ship or _ship.is_leaving_stage():
		return
	if _ship.action_terminator != null:
		return
	var prev_commit_times := _commit_times
	super()
	if _commit_times == (prev_commit_times + 1) and is_terminating:
		_ship.action_terminator = self
		return


func revert() -> void:
	if not _ship or _ship.is_leaving_stage():
		return
	if _ship.action_terminator != null:
		if _ship.action_terminator == self and revertible:
			# I terminate, I revert
			_ship.action_terminator = null
		else:
			return
	super()

	#func mark_map_layer() -> void:
	#var coord := Cursor.coord if follow_mouse else _ship.coord
	#if action_area:
	#action_area.offset = coord
	#Map.instance.action_layer.set_dict(_get_action_area())


func has_reached_commit_limit() -> bool:
	return super() or _ship.action_terminator != null
