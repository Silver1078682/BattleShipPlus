class_name Main
extends Node
## Main application logic.

const GAME_SCENE = preload("uid://b4hy2lm0osuvm")
@onready var start_menu: Control = %StartMenu
static var instance: Main

var cli := CmdLineInterface.new()


func _init() -> void:
	assert(not instance)
	instance = self
	cli.parse_and_apply(OS.get_cmdline_args())


func _ready() -> void:
	Log.debug("Main instance ready")


func _on_network_player_joined() -> void:
	start_game.rpc(Map.instance.map_name)


## Start a game
@rpc("any_peer", "call_local", "reliable")
func start_game(map_id: String) -> void:
	if not Map.instance:
		Map.instance = (ResourceUtil.load_resource("maps", map_id, null, "tscn") as PackedScene).instantiate()

	## No more connection after game started
	Network.instance.multiplayer.multiplayer_peer.refuse_new_connections = true
	if Game.instance:
		Log.error("A game instance ", Game.instance, "is already running")
	add_child(GAME_SCENE.instantiate())
	start_menu.waiting_screen.hide()
	start_menu.hide()


## Back to the main game menu
func back_to_main_menu() -> void:
	if Game.instance:
		Game.instance.queue_free()
	start_menu.show()

## Id allocator
static var _largest_used_id: int


static func generate_id() -> int:
	_largest_used_id += 1
	return _largest_used_id
