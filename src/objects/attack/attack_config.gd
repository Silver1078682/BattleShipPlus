class_name AttackConfig
extends Resource

@export var name: String

@export var friendly_fire := false
@export_group("anim")
@export var anim_scene: PackedScene = preload("uid://b1yerg1ur6ei8")
@export var texture: Texture2D
@export var flight_time: float = 1.0
@export var use_dice := false
## Whether an explosion and damage should be applied to the attacker itself
@export var should_explode := false
## On which occasion should the attack explode, ignored if should_explode set false
@export var explode_when := Attack.Result.FAILURE


#-----------------------------------------------------------------#
## Function used to push the attack, see [method push_attack]
func _push_attack(
		attack_damages: Dictionary[Vector2i, int],
		attack: Attack,
) -> void:
	_call_remote_handle(attack_damages, attack.serialized())


## Handle an attack and return its result
func _handle_attack(
		attack_damages: Dictionary,
		attack: Attack,
) -> Attack.Result:
	var hit_ships := Player.fleet.get_hit_ships(attack_damages, attack)
	push_mirror_request(hit_ships)
	if hit_ships.is_empty():
		return Attack.Result.MISS
	return Attack.Result.SUCCESS


#-----------------------------------------------------------------#
func push_mirror_request(warships_hit: Dictionary[Vector2i, Warship]) -> void:
	if warships_hit.is_empty():
		return
	var serialized_warships = Serializer.serialize_a_dictionary(warships_hit)
	Network.instance.rpc_call(^"MirrorRequest", &"create_mirrors_from_list", serialized_warships)


#-----------------------------------------------------------------#
## Invoked by [method Attack.push()]
func push_attack(
		attack_damages: Dictionary[Vector2i, int],
		attack: Attack,
) -> void:
	if attack_damages.is_empty() or attack == null:
		return
	Log.debug("pushing attack %s @ %s ..." % [attack, attack.center])
	_push_attack(attack_damages, attack)
	Log.debug("...          Attack pushed")


## Invoked by push_attack called by your opponent
## See [method push_attack]
func handle_attack(
		attack_damages: Dictionary,
		attack: Attack,
) -> void:
	Log.debug("Handling attack %s..." % attack)
	var attack_anim := attack.create_attack_anim()
	if attack_anim:
		Game.instance.add_child(attack_anim)
		attack_anim.play(attack_damages.keys())
		await attack_anim.request_attack

	attack.result = _handle_attack(attack_damages, attack)
	_reply_remote_attack(attack.id, attack.result)
	Log.debug("...Attack handled")


#-----------------------------------------------------------------#
func _call_remote_handle(
		attack_damages: Dictionary,
		serialized_attack: Dictionary,
) -> void:
	Network.instance.rpc_call(^"Player/Fleet", &"handle_attack", attack_damages, serialized_attack)


func _reply_remote_attack(attack_id: int, result: Attack.Result) -> void:
	Network.instance.rpc_call(^"Player/Fleet", &"end_attack", attack_id, result)


#-----------------------------------------------------------------#
func _to_string() -> String:
	return "ATK_CFG< %s%s %s>" % ["A" if anim_scene else "-", "D" if use_dice else "-", name]
