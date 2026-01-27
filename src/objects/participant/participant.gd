class_name Participant
extends Node2D
## Participant of the game, referring to a player

# Include following static variables in subclasses
# static var fleet: Fleet:
#	get:
#		return _fleet
# static var mine: MineManager:
#	get:
#		return _mine
# static var sunk: Sunk
# static var instance

var _fleet: Fleet
var _mine: MineManager
var _sunk: Sunk


func _ready() -> void:
	_fleet = $Fleet
	_mine = $Mine
	Log.debug(name, " instance ready")


func setup() -> void:
	Log.info(name, " instance setup")
	_setup()


func _setup() -> void:
	_fleet.setup()
	_sunk = UI.instance.sunk.get_node(String(name))
	Phase.manager.phase_changed.connect(_mine.push_mines.unbind(1))
