class_name Opponent
extends Participant

static var fleet: Fleet
static var mine: MineManager
static var sunk: Sunk
static var instance: Opponent = null


#-----------------------------------------------------------------#
func _ready() -> void:
	Opponent.instance = self
	super()


#-----------------------------------------------------------------#
func handle_death_request(type: StringName) -> void:
	sunk.add_sunk_ship(type)
