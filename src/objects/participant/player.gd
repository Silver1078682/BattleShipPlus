class_name Player
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

static var instance: Player = null

#-----------------------------------------------------------------#
## id for the player, 0 for host; 1 for client
static var id: int
const HOST_ID = 0
const CLIENT_ID = 1
## number of players in a game
const MAX_COUNT := 2


static func get_next_player(player_id: int) -> int:
	return (player_id + 1) % MAX_COUNT


#-----------------------------------------------------------------#
func _ready() -> void:
	Player.instance = self
	super()


func get_the_other_side() -> Participant:
	return Opponent.instance


func handle_death(dead_ship: Warship) -> void:
	super(dead_ship)
	if not dead_ship.config.action_aerial_scout.is_empty():
		var key_to_revert := AttackConfigScout.EXPOSURE_KEY + str(dead_ship.id)
		Network.instance.rpc_call(^"Player/Fleet", &"revert_exposure", key_to_revert)
