class_name Main
extends Node

const GAME_SCENE = preload("uid://b4hy2lm0osuvm")
@onready var start_menu: CanvasLayer = $StartMenu
static var instance: Main


func _init() -> void:
	assert(not instance)
	instance = self
	CmdLineInterface.parse(OS.get_cmdline_args())


func _ready() -> void:
	Log.debug("Main instance ready")


func _on_network_player_joined() -> void:
	start_game.rpc()


@rpc("any_peer", "call_local", "reliable")
func start_game() -> void:
	add_child(GAME_SCENE.instantiate())
	start_menu.hide()

## Id allocator
static var _largest_used_id: int


static func generate_id() -> int:
	_largest_used_id += 1
	return _largest_used_id
