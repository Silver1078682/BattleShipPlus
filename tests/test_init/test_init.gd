extends GutTest

func test_init():
	main = main_scene.instantiate()
	get_node("/root").add_child(main)
	assert_not_null(Main.instance)
	assert_not_null(Network.instance)

	watch_signals(Network.instance)
	watch_signals(Network.instance.multiplayer)

	await wait_seconds(1, "Scene setting up")
	if Network.is_server():
		assert_signal_emitted(Network.instance.player_joined)
	elif Network.is_client():
		assert_signal_emitted(Network.instance.multiplayer.connected_to_server)


var main_scene := preload("res://src/game/main.tscn")
var main: Main


func test_existence():
	assert_not_null(Game.instance)
	assert_not_null(Player.instance)
	assert_not_null(Opponent.instance)
	assert_not_null(Player.fleet)
	assert_not_null(Opponent.fleet)
