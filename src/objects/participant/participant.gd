class_name Participant
extends Node2D
## Participant of the game, referring to a player

# Include following static variables in subclasses
# static var fleet: Fleet
# static var mine: MineManager
# static var sunk: Sunk
# static var instance: Opponent = null

func _ready() -> void:
	set("fleet", $Fleet)
	set("mine", $Mine)
	Log.debug(name, "instance ready")


func setup() -> void:
	Log.info(name, " instance setup")
	_setup()


func _setup() -> void:
	get("fleet").setup()
	set("sunk", UI.instance.sunk.get_node(String(name)))
	Phase.manager.phase_changed.connect(get("mine").push_mines.unbind(1))
