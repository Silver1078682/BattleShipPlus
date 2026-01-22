class_name Player
extends Participant

static var fleet: Fleet
static var mine: MineManager
static var sunk: Sunk
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
