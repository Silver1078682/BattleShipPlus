class_name Player
extends Node2D

static var fleet: Fleet
static var mine: MineManager
static var instance: Player = null
static var sunk: Sunk

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
	fleet = $Fleet
	mine = $Mine
	Player.instance = self
	Log.debug("Player instance ready")


func setup() -> void:
	Log.info("Player instance setup")
	_setup()


func _setup() -> void:
	fleet.setup()
	sunk = UI.instance.sunk.get_node("Player")
	Phase.manager.phase_changed.connect(mine.push_mines.unbind(1))
