extends GutTest

func before_all():
	gut.p(Network.instance)
	assert_not_null(Phase.manager)


func before_each():
	## double the AttackRequest node.
	var attack_request = AttackRequest.new()
	assert_not_null(attack_request)
	if Game.instance.has_node("AttackRequest"):
		replace_node(Game.instance, "AttackRequest", attack_request)
	else:
		attack_request.name = "AttackRequest"
		Game.instance.add_child(attack_request, true)
	assert_true(Game.instance.has_node("AttackRequest"))


func test_next():
	if not Network.is_server():
		pass_test("not server side")
		return

	watch_signals(Phase.manager)
	for i in 10:
		var a = Phase.manager.get_phase()
		var turn = a.should_player_take_turn and \
		Phase.manager.player_turn_count < Player.MAX_COUNT
		Phase.manager.next_phase_or_turn()
		if turn:
			assert_signal_emitted(Phase.manager.turn_changed)
			var b = Phase.manager.get_phase()
			assert_same(a, b)
		else:
			assert_signal_emitted(Phase.manager.phase_changed)
			var b = Phase.manager.get_phase()
			assert_not_same(a, b)
