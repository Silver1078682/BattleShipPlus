@tool
class_name SpawnPoint
extends Node2D

@export var warship_type: StringName
@export var spawn_amount_max: int
@onready var base := get_parent()

#-----------------------------------------------------------------#
@export var coord := Vector2i.ZERO:
	set(p_coord):
		if is_node_ready():
			_set_coord(p_coord)
		coord = p_coord


func _set_coord(p_coord: Vector2i) -> void:
	var sea: Sea = base.get_map().get_node(^"%Sea")
	position = sea.map_to_local(p_coord) - sea.map_to_local(Vector2i.ZERO)


#-----------------------------------------------------------------#
func _ready() -> void:
	assert(base != null and base is Base)
	if warship_type not in Warship.NAMES:
		Log.error("Invalid warship type ", warship_type, " in ", self)

	await NodeUtil.ensure_ready(base.get_map())
	_set_coord(coord)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		var sea: Sea = base.get_map().get_node(^"%Sea")
		coord = sea.local_to_map(position + sea.map_to_local(Vector2i.ZERO))


func setup():
	_setup()


func _setup():
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
