class_name SpawnPoint
extends Node2D

@export var warship_type: StringName
@export var coord: Vector2i
@export var spawn_amount_max: int
@onready var base := get_parent()


#-----------------------------------------------------------------#
func _ready() -> void:
	assert(base != null and base is Base)
	assert(warship_type in Warship.NAMES)

	if base == (base.get_parent() as BaseManager).get_base(Player.id):
		Log.debug("SpawnPoint %s activated" % self)
		Phase.manager.round_over.connect(spawn)

#-----------------------------------------------------------------#
var _spawn_count: int


func add_a_spawn_reference() -> void:
	Log.debug("add spawn reference for SpawnPoint %s" % self)
	_spawn_count += 1


func delete_a_spawn_reference() -> void:
	Log.debug("delete spawn reference for SpawnPoint %s" % self)
	_spawn_count -= 1


#-----------------------------------------------------------------#
func spawn() -> void:
	_spawn()


func _spawn() -> void:
	var spawn_coord = base.coord + coord

	if Player.fleet.has_ship_at(spawn_coord):
		Anim.pop_up(tr("SPAWN_POINT_OCCUPIED") % tr(warship_type))
		return
	if Player.mine.has_mine_at(spawn_coord):
		Anim.pop_up(tr("SPAWN_POINT_OCCUPIED") % tr(warship_type))
		return
	if spawn_amount_max > 0 and _spawn_count >= spawn_amount_max:
		Anim.pop_up(tr("SPAWN_REACH_LIMIT") % tr(warship_type))
		return

	var warship := Warship.create_from_name(warship_type)
	warship.coord = spawn_coord
	Player.fleet.add_ship(warship)

	add_a_spawn_reference()
	warship.stage_left.connect(delete_a_spawn_reference)


#-----------------------------------------------------------------#
func _to_string() -> String:
	return "SP< %s [%d] > @%s" % [warship_type, _spawn_count, base.coord + coord]
