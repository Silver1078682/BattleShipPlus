class_name Phase
extends Resource
## Game phases
##
## [Phase] is a specific stage in a game.
## Each phase has a name as unique identifier.
## In a single phase, Player can perform actions in order or simultaneously.

static var manager: PhaseManager

## The name of the phase. Should match a Resource file with the same name in PHASE_PATH folder.
@export var name := "DefaultPhase"
@export var description := "This is a default phase."

## If set to true, players will take turns to perform actions.
## Otherwise, players can perform the action at the same time.
@export var should_player_take_turn := false


#-----------------------------------------------------------------#
func enter() -> void:
	Log.info("Entering phase: %s" % self.name)
	Anim.pop_up(self.name)
	_enter()


## Called when the phase is entered.
func _enter() -> void:
	pass


#-----------------------------------------------------------------#
func exit() -> void:
	Log.info("Exiting phase: %s" % self.name)
	_exit()


## Called when the phase is exited.
func _exit() -> void:
	pass

#-----------------------------------------------------------------#
static var _phase_load_cache: Dictionary[StringName, Phase] = { }


static func get_phase_from_name(phase_name: StringName) -> Phase:
	if phase_name in _phase_load_cache:
		return _phase_load_cache[phase_name]
	_phase_load_cache[phase_name] = ResourceUtil.load_resource("phases", phase_name) as Phase
	return _phase_load_cache[phase_name]


enum Type {
	SUPPLY,
	MOVEMENT,
	AERIAL_SCOUT,
	AERIAL_DEFENSE,
	AERIAL_ATTACK,
	ARTILLERY_ATTACK,
	TORPEDO_ATTACK,
	SUBMARINE_ATTACK,
}


#-----------------------------------------------------------------#
func _to_string() -> String:
	return "Phase: %s" % self.name
