class_name Game
extends Node2D
## Main game logic
##
## Access to nodes[br]
## Setting up scenes[br]

#-----------------------------------------------------------------#
## Node pointers
## [Camera] singleton
@onready var camera: Camera = $Camera2D
## [Cursor] singleton
@onready var cursor: Cursor = $Cursor
## [UI] singleton
@onready var ui: UI = %UI
## [Player] singleton
@onready var player: Player = $Player
## [Opponent] singleton
@onready var opponent: Opponent = $Opponent

#-----------------------------------------------------------------#
signal setup


# Load the scene synchronously
func _ready() -> void:
	if Map.instance == null:
		Log.error("a game start but no map is selected")
	NodeUtil.set_parent_of(Map.instance, self)
	await NodeUtil.ensure_ready(Map.instance)
	Map.instance.setup()

	player.setup()
	opponent.setup()
	await NodeUtil.ensure_ready(player)
	await NodeUtil.ensure_ready(opponent)

	camera.setup()
	ui.setup()
	camera.move_to_position(Map.instance.get_map_center(), false)

	if Network.is_server():
		Phase.manager.set_initial_phase()
		Network.instance.player_left.connect(end_game.bind(Result.SUCCESS, EndCondition.NETWORK_DISCONNECTED))
	elif Network.is_client():
		Network.instance.server_disconnected.connect(end_game.bind(Result.SUCCESS, EndCondition.NETWORK_DISCONNECTED))

	_initialize_readiness_confirmation()
	_initialize_failure_count()

	## TODO tech_point.max_value for each phase
	Card.manager.tech_point.max_value = ActionArrange.INITIAL_ARRANGE_MAX_COST
	setup.emit()
	Log.info("Game instance ready")

#-----------------------------------------------------------------#
var readiness_confirmation := Vote.new("ReadinessConfirmation")


func _initialize_readiness_confirmation() -> void:
	readiness_confirmation.voted.connect(_on_ready_voted)
	readiness_confirmation.vote_over.connect(_on_ready_vote_over)


func _on_ready_voted(_id: int) -> void:
	Log.info("Player is ready for the next phase")
	if _id == Player.id:
		_disable_action_entry()


func _on_ready_vote_over() -> void:
	if Network.is_server():
		Phase.manager.next_phase_or_turn()


func get_required_ready_player_count() -> int:
	return 1 if Phase.manager.get_phase().should_player_take_turn else Player.MAX_COUNT


#-----------------------------------------------------------------#
## Called right after a turn starts
@rpc("authority", "call_local")
func enter_turn() -> void:
	await Anim.sleep(0.2)
	await Anim.wait_anim()
	if Phase.manager.is_turn_of(Player.id):
		_enter_self_turn()
	else:
		_enter_opponent_turn()
	readiness_confirmation.vote_max_count = get_required_ready_player_count()


## Called right after a turn of the the local player starts
func _enter_self_turn() -> void:
	Player.fleet.update_ships()

	if not Card.manager.is_empty():
		return

	# pop up a notice if no ship has available action in this phase
	for ship in Player.fleet.get_ships():
		if ship.has_any_action():
			return
	Anim.pop_up("NOTHING_TO_DO")


## Called right after a turn of the your opponent starts
func _enter_opponent_turn() -> void:
	Card.manager.clear()
	Anim.pop_up("NOT_YOUR_TURN")


## Called right after a turn of the local player ends.
func exit_turn() -> void:
	_disable_action_entry()


# disable all UI entry of committing actions
func _disable_action_entry() -> void:
	Card.manager.clear()
	ActionButton.selected_button = null
	for ship in Player.fleet.get_ships():
		ship.action_button.hide()


## Called right after a whole round ends.
func exit_round() -> void:
	var end_condition := _check_game_over()
	Log.debug("check game over result: ", EndCondition.find_key(end_condition))
	failure_count.vote(end_condition)

#-----------------------------------------------------------------#
var failure_count := Vote.new("FailureCount")


func _initialize_failure_count() -> void:
	failure_count.vote_over.connect(_on_failure_count_vote_over)


func _on_failure_count_vote_over() -> void:
	var last_vote := failure_count.get_last_vote()
	var player_end_condition: EndCondition = last_vote.get(Player.id)
	last_vote.erase(Player.id)
	for enemy_id in last_vote:
		var opponent_end_condition: EndCondition = last_vote.get(enemy_id)

		var player_has_failed := (player_end_condition != Game.EndCondition.NONE)
		var opponent_has_failed := (player_end_condition != Game.EndCondition.NONE)

		if opponent_has_failed and player_has_failed:
			end_game(Game.Result.DRAW, player_end_condition)
		elif opponent_has_failed and not player_has_failed:
			end_game(Game.Result.SUCCESS, opponent_end_condition)
		elif not opponent_has_failed and player_has_failed:
			end_game(Game.Result.FAILURE, player_end_condition)

# Never end the game (expect for network disconnection), for debug purpose
var never_end_game := false


func _check_game_over() -> EndCondition:
	if OS.is_debug_build() and Game.instance.never_end_game:
		return EndCondition.NONE

	var has_valid_ship := false
	var has_valid_ship_in_home := false
	for ship in Player.fleet.get_ships():
		if not ship.config.name in [Warship.CARGO_SHIP, Warship.MINE_LAYER]:
			has_valid_ship = true
			if ship.coord in Map.instance.get_scope_home():
				has_valid_ship_in_home = true
				break

	if not has_valid_ship:
		return EndCondition.NO_VALID_SHIP
	if not has_valid_ship_in_home:
		pass ## TODO return EndCondition.ENEMY_AT_UNPROTECTED_HOME
	return EndCondition.NONE


enum Result {
	FAILURE = 0,
	DRAW = 1,
	SUCCESS = 2,
}

enum EndCondition {
	NONE = 0,
	NO_VALID_SHIP = 1,
	ENEMY_AT_UNPROTECTED_HOME = 2,
	NETWORK_DISCONNECTED = 3,
}

# gdlint-ignore-next-line variable-name
static var END_CONDITION_ARRAY = EndCondition.keys()


func end_game(result: Result, end_condition: EndCondition) -> void:
	UI.instance.ending_screen.display(result, end_condition)
	Log.info("Game ends: %s (%s)" % [Result.find_key(result), END_CONDITION_ARRAY[end_condition]])

#-----------------------------------------------------------------#
static var instance: Game


func _init() -> void:
	assert(not instance, "singleton instance initialized")
	instance = self
	Log.debug("Game instance initialized")
