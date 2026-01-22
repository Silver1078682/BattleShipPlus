class_name Attack
extends Resource

@export var center: Vector2i
@export var config: AttackConfig
@export var scouting := true
var base_damage := 0
var dice_result := -1
## Some extra information describing the attack, will be sent to your opponent's side
## useful for custom attack handler requiring info from attacker's side
var meta := { }
## Local meta that won't be sent to your opponent's side
var local_meta := { }


func create_attack_anim() -> AttackAnim:
	if not config or not config.anim_scene:
		return null
	var anim_attack: AttackAnim = config.anim_scene.instantiate()
	anim_attack.attack = self
	return anim_attack


#-----------------------------------------------------------------#
## Push the attack to the your opponent
func push(attack_damages: Dictionary[Vector2i, int]) -> void:
	config.push_attack(attack_damages, self)
	sessions[id] = self
	set_timeout()
	if config.friendly_fire:
		config.handle_attack(attack_damages, self)


var attacker: int
var id: int


func _init() -> void:
	attacker = Player.id
	id = Main.generate_id()

#-----------------------------------------------------------------#
static var sessions: Dictionary[int, Attack] = { }
signal finished
var _result: Result = Result.NOT_FINISHED
var result: Result:
	get:
		return _result
	set(p_result):
		if has_finished():
			Log.warning("The result of a finished attack(%s) can not be changed again" % self)
			return false
		if p_result == Result.NOT_FINISHED:
			Log.warning("can not set result of attack(%s) to NOT_FINISHED % self")
			return false

		_result = p_result
		Log.debug("%s finished with result id: %d" % [self, p_result])
		finished.emit()
		sessions.erase(id)
		return true

enum Result {
	NOT_FINISHED = 0, ## Attack is still running and result is unknown
	SUCCESS, ## Attack succeeded and at least one opponent is hit
	HALF_SUCCESS, ## Attack succeeded but cannot cause maximum damage due to game rules
	FAILURE, ## Attack Failed due to game rules
	MISS, ## No opponent is hit
	TIMEOUT, ## Attack timeout, due to network issue
}


#-----------------------------------------------------------------#
static func end(session_id: int, session_result: Result) -> void:
	if not session_id in sessions:
		return
	var attack := sessions[session_id]
	attack.result = session_result
	attack.config.end_attack(attack)
	sessions.erase(session_id)


func has_finished() -> bool:
	return _result != Result.NOT_FINISHED


func set_timeout() -> void:
	if not has_finished():
		await Anim.sleep(10)
		_result = Result.TIMEOUT
		finished.emit()


#-----------------------------------------------------------------#
func serialized() -> Dictionary[StringName, Variant]:
	return Serializer.serialize_by_properties(
		self,
		[&"center", &"scouting", &"dice_result", &"id", &"base_damage", &"meta"],
		{
			&"config": config.name if config else "",
			&"attacker": Player.id,
		},
	)


func deserialized(prop_list: Dictionary[StringName, Variant]) -> void:
	if prop_list.config:
		self.config = get_config(prop_list.config)
	else:
		Log.warning("creating a default attack")
		self.config = AttackConfig.new()
	Serializer.deserialize_by_properties(self, prop_list, [&"config"])


static func deserialize_from(prop_list: Dictionary[StringName, Variant]) -> Attack:
	var attack := Attack.new()
	attack.deserialized(prop_list)
	return attack


#-----------------------------------------------------------------#
## Returns a new instance of Attack with the provided AttackConfig
static func create_from_config(attack_config: AttackConfig) -> Attack:
	if not attack_config:
		Log.error("creating Attack from config null")
		return null

	var attack := Attack.new()
	attack.config = attack_config

	if attack.config.use_dice:
		attack.dice_result = randi_range(1, 6)

	return attack


## Returns a new instance of Attack with the provided name.
## See [create_from_config]
static func create_from_name(config_name: String) -> Attack:
	var attack_config := ResourceUtil.load_resource("attacks", config_name) as AttackConfig
	if not attack_config:
		return null

	return create_from_config(attack_config)


static func get_config(config_name: String) -> AttackConfig:
	return ResourceUtil.load_resource("attacks", config_name) as AttackConfig


#-----------------------------------------------------------------#
func _to_string() -> String:
	return "ATK< %s %s @%s [%d] %d>" % [
		"S" if scouting else "-",
		config.name,
		center,
		base_damage,
		id,
	]
