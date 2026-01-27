class_name Opponent
extends Participant

static var fleet: Fleet:
	get:
		return instance._fleet
static var mine: MineManager:
	get:
		return instance._mine
static var sunk: Sunk:
	get:
		return instance._sunk

static var instance: Opponent = null


#-----------------------------------------------------------------#
func _ready() -> void:
	Opponent.instance = self
	super()
