class_name PhaseManager
extends Node
## Manages the game phases and player turns
##
## This node manages the game phases and player turns.
## It is only enabled on server side.
## The client side only receives broadcast messages from the server
## Phases and Turns [br]
## Phase can includes multiple turns. in that case Players take turns to perform actions.
## Each [b]turn[/b] a Player can perform a sequence of [Action]s.
## A Phase can also include only one turn. in that case Players perform [Action]s simultaneously.
## See [Phase] for more information about game phases.

#-----------------------------------------------------------------#
## Emitted right after the game phase has changed.
signal phase_changed(p_phase: Phase)

## Emitted when a round is over, in other word, we have just gone through all phases
signal round_over

#-----------------------------------------------------------------#
var initial_phase := "Arrangement"
## Current: Next
var phases: Dictionary[StringName, StringName] = {
	&"Arrangement": "Movement",
	&"Supply": "Movement",
	&"Movement": "AerialScout",
	&"AerialScout": "AerialDefense",
	&"AerialDefense": "AerialAttack",
	&"AerialAttack": "ArtilleryAttack",
	&"ArtilleryAttack": "TorpedoAttack",
	&"TorpedoAttack": "SubmarineScout",
	&"SubmarineScout": "SubmarineAttack",
	&"SubmarineAttack": "Supply",
}


func get_next_phase_of(phase: Phase) -> Phase:
	return Phase.get_phase_from_name(phases[phase.name])


#-----------------------------------------------------------------#
func set_initial_phase() -> void:
	enter_phase_by_name(initial_phase)


## Go to the next phase or switch to the next player's turn.
func next_phase_or_turn() -> void:
	if _phase.should_player_take_turn and player_turn_count < Player.MAX_COUNT:
		# next turn
		var next_player := Player.get_next_player(_current_player)
		set_current_player(next_player)
		if player_turn_count == Player.MAX_COUNT:
			_change_first_player()
	else:
		# next phase
		enter_phase(get_next_phase_of(_phase))
	Game.instance.enter_turn.rpc()


#-----------------------------------------------------------------#
## Enter the given phase. This function affect every player.
func enter_phase(p_phase: Phase) -> void:
	if not multiplayer.is_server():
		Log.warning("enter_phase function called on client")
	_set_phase_by_name.rpc(p_phase.name)


## Enter the given phase by name. This function affect every player.
func enter_phase_by_name(p_phase_name: StringName) -> void:
	if not multiplayer.is_server():
		Log.warning("enter_phase function called on client")
	_set_phase_by_name.rpc(p_phase_name)

#-----------------------------------------------------------------#
var _phase: Phase


## Get the current phase.
func get_phase() -> Phase:
	return _phase


# Set the phase locally, Only call the function in rpc.
func _set_phase(p_phase: Phase) -> void:
	Game.instance.exit_turn()

	if _phase != p_phase:
		if _phase:
			_phase.exit()
		_phase = p_phase
		phase_changed.emit(p_phase)
		if p_phase:
			p_phase.enter()
	player_turn_count = 1

	if _phase.name == "Supply":
		Game.instance.exit_round()
		round_over.emit()


# Set the phase by name locally, Only call the function in rpc.
@rpc("authority", "call_local")
func _set_phase_by_name(p_phase_name: StringName) -> void:
	_set_phase(Phase.get_phase_from_name(p_phase_name))

#-----------------------------------------------------------------#
signal turn_changed
## Whose turn it is.
## Only used in [Phase]s where players perform actions in order.
var _current_player: int


## Switch to another player's turn. The function will affect every player.
func set_current_player(player_id: int) -> void:
	if player_id == _current_player:
		return
	_set_current_player.rpc(player_id)
	player_turn_count += 1


## Get the current player's id.
## Returns -1 when it is not a turn based phase
func get_current_player() -> int:
	return _current_player if _phase.should_player_take_turn else -1


@rpc("authority", "call_local")
func _set_current_player(player_id: int) -> void:
	Game.instance.exit_turn()
	Log.info("switching player's turn from %d to %d" % [_current_player, player_id])
	_current_player = player_id
	turn_changed.emit(player_id)

#-----------------------------------------------------------------#
# only be used by the server
## The player who should take the first move in this Phase.
## Only used in [Phase]s where players perform actions in order.
var current_first_player: int

# only be used by the server
## How many turns have been taken.
## Only used in [Phase]s where players perform actions in order.
var player_turn_count: int


func _change_first_player() -> void:
	current_first_player = Player.get_next_player(current_first_player)


func is_turn_of(player_id := Player.id) -> bool:
	return _current_player == player_id or _phase.should_player_take_turn == false


#-----------------------------------------------------------------#
func _init() -> void:
	Phase.manager = self


func _ready() -> void:
	Log.debug("Phase Manager Ready")
