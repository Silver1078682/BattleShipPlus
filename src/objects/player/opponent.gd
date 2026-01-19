class_name Opponent
extends Node

static var fleet: Fleet
static var mine: MineManager
static var sunk: Sunk
static var instance: Opponent = null


#-----------------------------------------------------------------#
func _ready() -> void:
	fleet = $Fleet
	mine = $Mine
	Opponent.instance = self
	Log.debug("Opponent instance ready")


func setup() -> void:
	Log.info("Opponent instance setup")
	_setup()


func _setup() -> void:
	fleet.setup()
	sunk = UI.instance.sunk.get_node("Opponent")
	Phase.manager.phase_changed.connect(mine.push_mines.unbind(1))

## warships that is hit at least once this round.
var warships_just_hit: Array[Warship]


func remove_type_labels() -> void:
	for warship in warships_just_hit:
		if is_instance_valid(warship):
			warship.label.hide()
	warships_just_hit.clear()


#-----------------------------------------------------------------#
func handle_death_request(type: StringName) -> void:
	sunk.add_sunk_ship(type)
