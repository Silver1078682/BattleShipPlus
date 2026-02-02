class_name GutTestGame
extends GutTest

func assert_full_env():
	assert_not_null(Game.instance)
	assert_not_null(Player.instance)
	assert_not_null(Opponent.instance)
	assert_not_null(Player.fleet)
	assert_not_null(Opponent.fleet)
