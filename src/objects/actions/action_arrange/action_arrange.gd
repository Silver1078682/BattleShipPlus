class_name ActionArrange
extends Action
## [Action] of arranging ships, used in [PhaseArrangement]

var warship_config: WarshipConfig:
	set(p_warship_config):
		if p_warship_config:
			max_commit_times = p_warship_config.arrange_limit

		committed.connect(_check_arrange_limit)
		reverted.connect(_check_arrange_limit)

		warship_config = p_warship_config

#-----------------------------------------------------------------#
# The preview warship
static var _warship_preview: Warship

## Coordinate and corresponding source
static var _staging: Dictionary[Vector2i, ActionArrange]


#-----------------------------------------------------------------#
func _started() -> void:
	_check_arrange_limit()
	if _warship_preview:
		_warship_preview.queue_free()
	_warship_preview = Warship.create_from_config(warship_config)
	if _warship_preview:
		_make_warship_preview(_warship_preview)


func _make_warship_preview(warship: Warship) -> void:
	warship.modulate.a = 0.5
	var snapped_cursor := Game.instance.cursor.snapped_cursor
	snapped_cursor.add_child(warship)


#-----------------------------------------------------------------#
func _committed() -> bool:
	if not _warship_preview:
		return false
	if not Game.instance.cursor.is_valid(true):
		return false

	return confirm_arrangement_at(Cursor.coord)


# confirm to arrange the current warship at [coord]
func confirm_arrangement_at(coord: Vector2i) -> bool:
	if not _warship_preview:
		return false
	if not Game.instance.cursor.is_valid():
		return false

	var warship := Warship.create_from_config(warship_config)
	warship.coord = coord

	if not Player.fleet.has_ship_at(coord):
		Player.fleet.add_ship(warship, true)

	_staging[coord] = self
	Card.manager.tech_point.value += warship_config.cost

	check_cursor(Cursor.coord)
	_check_arrange_limit()
	return true


#-----------------------------------------------------------------#
func _input(event: InputEvent) -> bool:
	if event.is_action("cancel"):
		cancel_ship_at(Cursor.coord)
		return true
	return false


# Cancel the arrangement at [param coord].
func cancel_ship_at(coord: Vector2i) -> void:
	if not coord in _staging:
		return

	var warship := Player.fleet.get_ship_at(coord)
	warship.leave_stage()
	Player.fleet.remove_ship_at(coord)

	var action = _staging[coord]
	_staging.erase(coord)
	action.revert()


## Cancel all arrangement in this phase.
func cancel_all_ships() -> void:
	for coord: Vector2i in _staging:
		cancel_ship_at(coord)


#-----------------------------------------------------------------#
func _cancelled() -> void:
	super()
	if _warship_preview:
		_warship_preview.queue_free()
		_warship_preview = null


# The Game.instance.map.scope.clear_mask() is not called here
func revert() -> void:
	if has_committed():
		if _reverted():
			Log.debug("Action %s reverted" % self)
			_commit_times -= 1
			reverted.emit()


func _reverted() -> bool:
	Card.manager.tech_point.value -= warship_config.cost
	check_cursor(Cursor.coord)
	_check_arrange_limit()
	return true


#-----------------------------------------------------------------#
func _get_action_area() -> Dictionary[Vector2i, int]:
	var map := Game.instance.map
	match warship_config.arrange_area:
		WarshipConfig.ArrangeArea.PUBLIC:
			return map.get_scope_public()
		WarshipConfig.ArrangeArea.HOME:
			return map.get_scope_home()
	return { }


#-----------------------------------------------------------------#
func _get_cursor_check_list(p_coord: Vector2i) -> Dictionary[String, bool]:
	return {
		"NOT_IN_MAP": Game.instance.map.has_coord(p_coord),
		"CANNOT_ARRANGE_HERE": Game.instance.map.scope.has_coord(p_coord),
		"OCCUPIED": not Player.fleet.has_ship_at(p_coord) or not check_cursor_fleet,
		"OCCUPIED_BY_MINE": not Player.mine.has_mine_at(p_coord) or not check_cursor_mine,
		"CANNOT_ARRANGE_BASE": p_coord != Game.instance.map.get_base().coord,
		"NOT_ENOUGH_SHIP": not _has_reached_arrange_limit,
		"NOT_ENOUGH_FUND": not _has_reached_tech_point_limit,
	}

#-----------------------------------------------------------------#
var _has_reached_arrange_limit := false
var _has_reached_tech_point_limit := false


func _check_arrange_limit() -> void:
	var total_cost := Card.manager.tech_point.value + warship_config.cost
	_has_reached_tech_point_limit = total_cost > Card.manager.tech_point.max_value
	_has_reached_arrange_limit = has_reached_commit_limit()


#-----------------------------------------------------------------#
func _get_icon() -> Texture:
	return Warship.get_texture(warship_config.name) if warship_config else null


func _get_action_name() -> String:
	return warship_config.name if warship_config else ""


func _get_description() -> String:
	return str(warship_config)


func _to_string() -> String:
	return super() % warship_config.abbreviation
#-----------------------------------------------------------------#
## The tech_point limits
const INITIAL_ARRANGE_MAX_COST := 30
const INITIAL_ARRANGE: Dictionary[String, int] = {
	Warship.DESTROYER: 0,
	Warship.LIGHT_CRUISER: 0,
	Warship.HEAVY_CRUISER: 0,
	Warship.BATTLESHIP: 0,
	Warship.CARRIER: 0,
	Warship.SUBMARINE: 0,
}
