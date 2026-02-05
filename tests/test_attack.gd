extends GutTest

func before_all():
	pass


#-----------------------------------------------------------------#
class TestGeneral extends AttackTest:
	func test_attack_init():
		var attacks: Array = ResourceUtil.load_directory("attacks")
		for cfg in attacks:
			var attack := Attack.create_from_config(cfg)
			assert_init(attack)


	func test_attack():
		var cfg := AttackConfig.new()
		cfg.friendly_fire = false
		cfg.use_dice = false
		var atk = Attack.create_from_config(cfg)
		assert_init(atk)
		assert_eq(atk.dice_result, -1)


	func test_attack_dice_result():
		var cfg := AttackConfig.new()
		cfg.friendly_fire = false
		cfg.use_dice = true
		var atk = Attack.create_from_config(cfg)
		assert_init(atk)
		assert_between(atk.dice_result, 1, 6)


	func test_attack_wont_push():
		Attack.create_from_name("Default").launch({ })
		assert_not_called(pd.push_attack)


#-----------------------------------------------------------------#
class TestSuccess extends AttackNetworkTest:
	func _test_push():
		attack = create_atk("Default")
		attack.launch({ Vector2i.ZERO: 0, Vector2i.ONE: 1 })


	func _test_result():
		examine_fleet(
			{
				Vector2i.ZERO: assert_warship_take_damage.bind(1, true),
				Vector2i.ONE: assert_warship_take_damage.bind(2, true),
			},
		)


	func _test_reply():
		assert_eq(attack.result, Attack.Result.SUCCESS)


#-----------------------------------------------------------------#
class TestMiss extends AttackNetworkTest:
	func _test_push():
		attack = create_atk("Default")
		attack.launch({ Vector2i(-1, -1): 1 })


	func _test_result():
		examine_fleet({ })


	func _test_reply():
		assert_eq(attack.result, Attack.Result.MISS)


#-----------------------------------------------------------------#
class TestKill extends AttackNetworkTest:
	func _test_push():
		attack = create_atk("Default")
		attack.launch({ Vector2i.ZERO: MAX_HEALTH })


	func _test_result():
		examine_fleet({ Vector2i.ZERO: assert_null })
		assert_eq(Player.sunk.get_sunk_ship_count(SHIP_TYPE), 1, "A ship killed")


	func _test_reply():
		assert_eq(attack.result, Attack.Result.SUCCESS, "should success")
		assert_eq(Opponent.sunk.get_sunk_ship_count(SHIP_TYPE), 1, "A ship killed")

# class TestPass extends AttackNetworkTest:
# 	func _test_push():
# 		attack = create_atk("Default")
# 		attack.launch({ Vector2i.ZERO: MAX_HEALTH })

# 	func _test_result():
# 		examine_fleet({ Vector2i.ZERO: assert_null })
# 		assert_eq(Player.sunk.get_sunk_ship_count(SHIP_TYPE), 1, "A ship killed")

# 	func _test_reply():
# 		assert_eq(attack.result, Attack.Result.SUCCESS, "should success")
# 		assert_eq(Opponent.sunk.get_sunk_ship_count(SHIP_TYPE), 1, "A ship killed")


#-----------------------------------------------------------------#
#-----------------------------------------------------------------#
class AttackNetworkTest extends AttackTest:
	func _get_attack_to_test() -> Attack:
		attack = create_atk("Default")
		return attack


	func _test_push():
		_get_attack_to_test()
		attack.launch({ })


	func _test_result():
		examine_fleet({ })


	func _test_reply():
		assert_eq(attack.result, Attack.Result.SUCCESS)

	#-----------------------------------------------------------------#
	var rect: AreaRect


	func test_client():
		if not Network.is_client():
			return

		rect = AreaRect.new()
		rect.size = Vector2i.ONE * 3
		rect.offset = Vector2i.ZERO
		for coord in rect.get_coords():
			Player.fleet.add_ship_at(Warship.create_from_name(SHIP_TYPE), coord)

		await wait_seconds(5)
		assert_called(pd.handle_attack)
		_test_result()


	var attack: Attack


	func test_server():
		if not Network.is_server():
			return

		assert_true(Game.instance.has_node(^"AttackRequest"))
		_test_push()
		watch_signals(attack)

		assert_called(pd.push_attack)

		await wait_seconds(5)

		assert_called(pd.end_attack)
		assert_signal_emitted(attack.finished)
		_test_reply()


	#-----------------------------------------------------------------#
	func examine_fleet(assert_mapping: Dictionary[Vector2i, Callable]):
		for coord in rect.get_coords():
			var warship := Player.fleet.get_ship_at(coord)
			var assert_function = assert_mapping.get(coord, assert_warship_untouched)
			assert_function.call(warship)


	func assert_warship_untouched(warship):
		assert_warship_take_damage(warship, 0, false)


	func assert_warship_take_damage(warship: Warship, damage: int, scouted := true):
		assert_not_null(warship)
		assert_eq(warship.is_exposed(), scouted)
		assert_eq(warship.health, MAX_HEALTH - damage, str(warship.coord, "\t", damage))

	#-----------------------------------------------------------------#


class AttackTest extends GutTest:
	const SHIP_TYPE = "Battleship"
	static var MAX_HEALTH = Warship.get_config(SHIP_TYPE).health #gdlint-ignore
	var pd: AttackRequest


	func before_each():
		## double the AttackRequest node.
		pd = partial_double(AttackRequest).new()
		assert_not_null(pd)
		if Game.instance.has_node("AttackRequest"):
			replace_node(Game.instance, "AttackRequest", pd)
		else:
			pd.name = "AttackRequest"
			Game.instance.add_child(pd, true)
		assert_true(Game.instance.has_node("AttackRequest"))
		watch_signals(pd)


	func after_all():
		for ship in Player.fleet.get_ships():
			ship.leave_stage()
		assert_true(Player.fleet.get_ships().is_empty())


	func assert_init(atk: Attack):
		assert_eq(atk.attacker, Player.id)
		assert_not_null(atk.config)


	func create_atk(attack_name: String, center := Vector2i.ZERO, meta: Dictionary = { }) -> Attack:
		var atk := Attack.create_from_name(attack_name)
		assert_init(atk)
		atk.base_damage = 1
		atk.center = center
		atk.meta = meta
		return atk
