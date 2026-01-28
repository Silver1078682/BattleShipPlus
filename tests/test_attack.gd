extends GutTest

var pd: AttackRequest


func before_each():
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
	Attack.new().launch({ })
	Attack.create_from_name("Default")


func test_attack_client():
	if not Network.is_client():
		return

	var rect := AreaRect.new()
	rect.size = Vector2i.ONE * 3
	rect.offset = Vector2i.ZERO

	const TYPE = "Battleship"
	var max_health = Warship.get_config(TYPE).health
	for coord in rect.get_coords():
		Player.fleet.add_ship_at(Warship.create_from_name(TYPE), coord)

	await wait_seconds(2)
	assert_called(pd.handle_attack)

	for coord in rect.get_coords():
		var warship := Player.fleet.get_ship_at(coord)
		assert_not_null(warship)
		var health := warship.health
		if coord == Vector2i.ZERO:
			assert_eq(health, max_health - 1, "at" + str(coord))
		elif coord == Vector2i.ONE:
			assert_eq(health, max_health - 2, "at" + str(coord))
		else:
			assert_eq(health, max_health, "at" + str(coord))


func test_attack_server():
	if not Network.is_server():
		return

	assert_true(Game.instance.has_node(^"AttackRequest"))
	var attack := create_atk_test()
	watch_signals(attack)
	attack.launch({ Vector2i.ZERO: 0, Vector2i.ONE: 1 })

	assert_called(pd.push_attack)

	await wait_seconds(2)

	assert_called(pd.end_attack)
	assert_signal_emitted(attack.finished)
	assert_eq(attack.result, Attack.Result.SUCCESS)


func create_atk_test() -> Attack:
	var atk := Attack.create_from_name("Default")
	assert_init(atk)
	atk.base_damage = 1
	atk.center = Vector2i.ONE
	atk.local_meta = { "local_meta": 12 }
	atk.meta = { "meta": 12 }
	return atk


func assert_init(atk: Attack):
	assert_eq(atk.attacker, Player.id)
	assert_not_null(atk.config)
