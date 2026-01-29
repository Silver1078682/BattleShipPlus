class_name Fleet
extends Node2D
## Fleet class managing a group of ships.

var _warships: Dictionary[Vector2i, Warship] = { }
@export var is_enemy_mirror := false


func setup() -> void:
	_setup()


func _setup() -> void:
	Phase.manager.round_over.connect(unhighlight_all_warships)


#-----------------------------------------------------------------#
func get_coords() -> Array[Vector2i]:
	return _warships.keys()


func get_ships() -> Array[Warship]:
	return _warships.values()


func get_ship_at(coord: Vector2i) -> Warship:
	return _warships.get(coord, null)


#-----------------------------------------------------------------#
## Add a ship, assign it with a new unique identifier by default
func add_ship(ship: Warship, auto_indexing := true) -> void:
	if not _add_ship_check(ship, ship.coord):
		return
	_add_ship(ship, auto_indexing)


## Add a ship at certain coord
func add_ship_at(ship: Warship, coord: Vector2i, auto_indexing := true) -> void:
	if not _add_ship_check(ship, coord):
		return
	ship.coord = coord
	_add_ship(ship, auto_indexing)


# used internally
func _add_ship_check(ship: Warship, coord: Vector2i) -> bool:
	if ship.get_parent() != null:
		Log.error("ship already in fleet")
		return false
	if coord in _warships:
		Log.error("The tile is occupied")
		return false
	return true


# used internally
func _add_ship(ship: Warship, auto_indexing := true) -> void:
	if auto_indexing:
		ship.id = Main.generate_id()
		ship.name = "Warship" + str(ship.id)

	NodeUtil.set_parent_of(ship, self)
	ship.stage_left.connect(_erase_ship.bind(ship.coord))
	_warships[ship.coord] = ship

	Log.debug("warship added %s" % ship)


## Returns true if the cell at [param coord] is occupied by a ship in this fleet.
func has_ship_at(coord: Vector2i) -> bool:
	return coord in _warships


#-----------------------------------------------------------------#
## Move a ship to a new coordinate.
## This function does not update the ship itself
## Setting ship.coord to coord manually is required
func move_ship_to(ship: Warship, coord: Vector2i) -> bool:
	if _warships.get(ship.coord) != ship:
		Log.error("Ship %s not found at %s" % [ship, ship.coord])
		return false
	if has_ship_at(coord):
		Log.warning("There is already a ship at %s" % [ship.coord])
		return false
	_warships.erase(ship.coord)
	ship.stage_left.disconnect(_erase_ship)
	ship.coord = coord
	ship.stage_left.connect(_erase_ship.bind(coord))
	_warships[coord] = ship
	return true


func _erase_ship(coord: Vector2i) -> void:
	_warships.erase(coord)


#-----------------------------------------------------------------#
# Call [method Warship update] on each ship
# pop up a notice if no ship has available action in this phase
func update_ships() -> void:
	if is_enemy_mirror:
		Log.error("enemy mirror should not call update function")

	Log.debug("Trying to update ships")
	for warship: Warship in get_children():
		warship.update()


# get the damages dictionary caused by collision
func get_collision_damages() -> Dictionary[Vector2i, int]:
	var damages: Dictionary[Vector2i, int] = { }
	for coord in _warships:
		var warship: Warship = _warships[coord]
		if warship.config.abbreviation == "SS":
			continue
		damages[coord] = 0
	return damages

#-----------------------------------------------------------------#
## destroyed
var warship_destroyed: Array[StringName]

#-----------------------------------------------------------------#
## _warships that is hit at least once this round.
var warships_just_hit: Array[Warship]


func unhighlight_all_warships() -> void:
	for warship in warships_just_hit:
		if is_instance_valid(warship):
			warship.is_highlighted = false
	warships_just_hit.clear()


#-----------------------------------------------------------------#
func get_aerial_defense_level_at(coord: Vector2i) -> int:
	var ship := get_ship_at(coord)
	var result := ship.config.aerial_defense if ship else 0

	for surrounding_coord: Vector2i in Map.instance.sea.get_surrounding_cells(coord):
		if has_ship_at(surrounding_coord):
			var surrounding_ship := get_ship_at(surrounding_coord)
			if surrounding_ship.config.abbreviation in ["CL", "DD"]:
				result += surrounding_ship.config.aerial_defense
	return result


#-----------------------------------------------------------------#
func get_hit_ships(attack_damages: Dictionary, attack: Attack) -> Dictionary[Vector2i, Warship]:
	var hit_ships: Dictionary[Vector2i, Warship] = { }

	var hit_coords: Array[Vector2i]
	for coord in Player.fleet.get_coords():
		if coord in attack_damages:
			hit_coords.append(coord)
	for coord in hit_coords:
		var warship := Player.fleet.get_ship_at(coord)
		var damage := (attack_damages[coord] as int) + attack.base_damage
		if warship.handle_attack(damage, attack):
			hit_ships[coord] = warship
	return hit_ships


func revert_exposure(exposure_key: String):
	Log.debug("reverting exposure_key ", exposure_key, " on fleet")
	for ship: Warship in Player.fleet.get_ships():
		ship.revert_exposure(exposure_key)
