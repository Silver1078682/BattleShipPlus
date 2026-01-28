@abstract
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


func handle_death(dead_ship: Warship) -> void:
	_sunk.add_sunk_ship(dead_ship.config.name)

	if not dead_ship.config.action_aerial_scout.is_empty():
		for ship: Warship in get_the_other_side().fleet.get_ships():
			var exposure_key := AttackConfigAerialScout.EXPOSURE_KEY + str(dead_ship.id)
			ship.revert_exposure(exposure_key)


@abstract func get_the_other_side() -> Participant
