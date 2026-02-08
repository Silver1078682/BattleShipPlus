extends GutTestGame

func before_all():
	clear_fleet()


func before_each():
	clear_fleet()


#-----------------------------------------------------------------#
func test_warship_init():
	var ship := Warship.new()
	assert_not_null(ship)
	for i in Warship.NAMES:
		_test_a_ship_type_init(i)
	ship.queue_free()


@warning_ignore("shadowed_variable")
func _test_a_ship_type_init(type: StringName):
	var cfg := Warship.get_config(type)
	var ship_cfg := Warship.create_from_config(cfg)
	var ship_name := Warship.create_from_name(type)
	var test = func(ship):
		assert_not_null(ship)
		assert_not_null(ship.config)
		assert_eq(ship.config.name, type)
	test.call(ship_cfg)
	test.call(ship_name)
	ship_cfg.queue_free()
	ship_name.queue_free()

#-----------------------------------------------------------------#
var fleet: Fleet:
	get:
		return Player.fleet
var type = Warship.NAMES[randi_range(0, Warship.NAMES.size() - 1)]


func add_ship(coord) -> Warship:
	var ship := Warship.create_from_name(type)
	fleet.add_ship_at(ship, coord)
	return ship


func clear_fleet():
	for ship in fleet.get_ships():
		assert_sync(ship)
		ship.leave_stage()
		assert_is_leaving(ship)
	assert_true(fleet.get_ships().is_empty(), "fleet not empty after clear")


#-----------------------------------------------------------------#
func test_add():
	var ship1 := Warship.create_from_name(type)
	ship1.coord = Vector2i.ZERO
	fleet.add_ship(ship1)
	assert_sync(ship1, Vector2i.ZERO)

	var ship2 := Warship.create_from_name(type)
	var coord2 = Vector2i(2, 0)
	ship2.coord = coord2
	fleet.add_ship(ship2)
	assert_sync(ship2, coord2)

	var ship3 := Warship.create_from_name(type)
	var coord3 = Vector2i(3, 0)
	fleet.add_ship_at(ship3, coord3)
	assert_sync(ship3, coord3)


func test_bad_add():
	var coord := Vector2i(1, 10)
	assert_sync(add_ship(coord))
	add_ship(coord)

	assert_push_error("tile is occupied")


func test_multi_add():
	clear_fleet()
	var ship := Warship.create_from_name(type)
	fleet.add_ship_at(ship, Vector2i(1, 2))
	assert_sync(ship)

	fleet.add_ship(ship)
	assert_push_error("ship already")
	fleet.add_ship_at(ship, Vector2i(2, 2))
	assert_push_error_count(2)

	assert_sync(ship)


func test_remove():
	for ship in fleet.get_ships():
		watch_signals(ship)
		assert_sync(ship)
		ship.leave_stage()
		assert_is_leaving(ship)
		assert_signal_emitted(ship.stage_left)


func test_bad_remove():
	var ship := Warship.create_from_name(type)
	ship.leave_stage()
	assert_push_warning("orphan ship leaving")
	fleet.add_ship_at(ship, Vector2i.ZERO)
	assert_sync(ship)

	ship.leave_stage()
	assert_is_leaving(ship)
	ship.leave_stage()
	assert_push_warning("already leaving")

	assert_true(fleet.get_coords().is_empty())


#-----------------------------------------------------------------#
func test_move_ship_push():
	const C1 = Vector2i.ONE * 1
	const C2 = Vector2i.ONE * 2
	const C3 = Vector2i.ONE * 3
	var ship = add_ship(C1)
	assert_sync(ship)

	fleet.move_ship_to(ship, C2)
	assert_sync(ship, C2)
	assert_has(fleet.movement_push, ship)
	assert_eq(fleet.movement_push[ship], C1)

	fleet.move_ship_to(ship, C3)
	assert_sync(ship, C3)
	assert_has(fleet.movement_push, ship)
	assert_eq(fleet.movement_push[ship], C1)
	fleet.movement_push.clear()


func test_move_ship_no_push():
	var ship = add_ship(Vector2i.ONE)
	assert_sync(ship)
	fleet.move_ship_to(ship, Vector2i.ZERO, false)
	assert_sync(ship, Vector2i.ZERO)

	assert_true(fleet.movement_push.is_empty())
	fleet.movement_push.clear()


func test_bad_move_ship():
	var ship = add_ship(Vector2i.ONE)
	assert_sync(ship)
	fleet.move_ship_to(ship, Vector2i.ONE)
	assert_push_warning("already a ship")

	assert_true(fleet.movement_push.is_empty())
	fleet.movement_push.clear()


func test_bad_move_ship2():
	var ship2 := Warship.create_from_name(type)
	fleet.move_ship_to(ship2, Vector2i.ONE)
	assert_push_error("not found")
	assert_true(fleet.movement_push.is_empty())

#-----------------------------------------------------------------#
const MOVE_SHIP_COORDS_FROM = [Vector2i.ONE, Vector2i.DOWN, Vector2i.LEFT]
const MOVE_SHIP_COORDS_TO = [Vector2i.LEFT, Vector2i.ONE, Vector2i.DOWN]


func test_move_ships():
	for coord in MOVE_SHIP_COORDS_FROM:
		add_ship(coord)
	fleet.move_ships_to(MOVE_SHIP_COORDS_FROM, MOVE_SHIP_COORDS_FROM.map(func(a): return a * 2))
	for coord in MOVE_SHIP_COORDS_FROM.map(func(a): return a * 2):
		assert_sync(fleet.get_ship_at(coord), coord)


func test_move_ships2():
	for coord in MOVE_SHIP_COORDS_FROM:
		add_ship(coord)
	fleet.move_ships_to(MOVE_SHIP_COORDS_FROM, MOVE_SHIP_COORDS_TO)
	for coord in MOVE_SHIP_COORDS_TO:
		assert_sync(fleet.get_ship_at(coord), coord)


#-----------------------------------------------------------------#
func test_serialized_ship():
	var ship := add_ship(Vector2i.ZERO)
	assert_sync(ship)
	var serialized := ship.serialized()
	assert_serial(serialized, ship)
	var ship2 := add_ship(Vector2i.ONE)
	assert_sync(ship2)
	var serialized2 := ship2.serialized()
	assert_serial(serialized2, ship2)


func assert_serial(serialized, ship: Warship):
	assert_true(serialized is Dictionary)
	assert_has(serialized, "id")
	assert_eq(serialized.get("id"), ship.id)
	assert_has(serialized, "coord")
	assert_eq(serialized.get("coord"), ship.coord)
	assert_has(serialized, "health")
	assert_eq(serialized.get("health"), ship.health)


#-----------------------------------------------------------------#
# a ideal state of a ship in the stage
func assert_sync(ship: Warship, coord = null):
	assert_not_freed(ship, "freed")
	assert_not_null(ship, "null")
	assert_eq(ship.get_parent(), fleet, "should have valid parent")
	assert_eq(fleet.get_ship_at(ship.coord), ship, "not register at fleet")
	assert_eq(ship.position, Map.coord_to_pos(ship.coord))
	assert_connected(ship.stage_left, fleet._erase_ship)
	assert_true(ship.name.ends_with(str(ship.id)))
	if coord != null:
		assert_eq(ship.coord, coord, "ship not at expected coord")


func assert_is_leaving(ship: Warship):
	assert_true(ship.is_leaving_stage())
	assert_true(not is_instance_valid(ship) or ship.is_queued_for_deletion())
	assert_false(fleet.has_ship_at(ship.coord))


func assert_orphan(ship: Warship):
	assert_null(ship.get_parent())
