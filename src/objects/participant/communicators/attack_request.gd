class_name AttackRequest
extends Node

static var sessions: Dictionary[int, Attack] = { }


## Push an attack to your opponent
func push_attack(attack_damages: Dictionary, attack: Attack) -> void:
	Network.instance.rpc_call(^"AttackRequest", &"handle_attack", attack_damages, attack.serialized())
	sessions[attack.id] = attack
	attack.set_timeout()


func handle_attack(attack_damages: Dictionary, serialized_attack: Dictionary) -> void:
	var attack := Attack.deserialize_from(serialized_attack)
	attack.config.handle_attack(attack_damages, attack)


func end_attack(session_id: int, session_result: Attack.Result) -> void:
	if not session_id in sessions:
		return
	var attack := sessions[session_id]
	attack.result = session_result
	attack.config.end_attack(attack)
	sessions.erase(session_id)
	Log.debug("%s finished with result id: %d" % [attack, session_result])
