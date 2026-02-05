class_name ActionRepair
extends ActionOperation

#-----------------------------------------------------------------#
var _has_repaired := false
var _ship_coord_just_repaired: Vector2i
var _previous_health: int
var _previous_torpedo: int


func _started() -> void:
	_has_repaired = false


func _committed() -> bool:
	if not Game.instance.cursor.is_valid(true):
		return false

	repair_ship(Cursor.coord)
	Phase.manager.phase_changed.connect(fade_and_leave_stage.unbind(1), CONNECT_ONE_SHOT)
	return true


func _reverted() -> bool:
	Phase.manager.phase_changed.disconnect(fade_and_leave_stage)
	return _revert_repair_ship()


func fade_and_leave_stage() -> void:
	if not is_instance_valid(_ship):
		Log.warning("_ship not valid", " leave_stage not calling" if has_committed() else "")
	if has_committed():
		_ship.anim_process.tween_property(_ship, "modulate:a", 0, 1.0).finished.connect(_ship.leave_stage)
		# We can not do "await tweener.finished & _ship.leave_stage" because the Action will be freed
		# So the await process is aborted


#-----------------------------------------------------------------#
func _get_cursor_check_list(p_coord: Vector2i) -> Dictionary[String, bool]:
	var has_ship := Player.fleet.has_ship_at(p_coord)
	var answer: Dictionary[String, bool] = {
		"NOT_IN_MAP": Map.instance.has_coord(p_coord),
		"NO_WARSHIP": has_ship,
		"CANNOT_ARRANGE_BASE": p_coord != Map.instance.get_base().coord,
	}
	if has_ship:
		var warship = Player.fleet.get_ship_at(p_coord)
		answer["NO_REPAIRING_REQUIRED"] = should_repair_ship(warship)

	return answer

#-----------------------------------------------------------------#
const HEALTH_RECOVER_RATE := 0.5


func repair_ship(target: Vector2i) -> bool:
	var warship := get_ship_at(target)
	if not warship:
		return false

	_has_repaired = true
	_ship_coord_just_repaired = target
	_previous_health = warship.health
	_previous_torpedo = warship.torpedo

	var recovered_health := floori(warship.config.health * HEALTH_RECOVER_RATE)
	warship.health = clampi(warship.health + recovered_health, 0, warship.config.health)
	warship.torpedo = warship.config.torpedo
	return true


func _revert_repair_ship() -> bool:
	if not _has_repaired:
		return true
	var warship := get_ship_at(_ship_coord_just_repaired)
	if not warship:
		return false

	warship.health = _previous_health
	warship.torpedo = _previous_torpedo
	return true
#-----------------------------------------------------------------#


func should_repair_ship(warship: Warship) -> bool:
	var low_health := warship.health != warship.config.health
	var low_torpedo := warship.torpedo != warship.config.torpedo
	return low_health or low_torpedo


func get_ship_at(target: Vector2i) -> Warship:
	if not Player.fleet.has_ship_at(target):
		return null
	return Player.fleet.get_ship_at(target)
