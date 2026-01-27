class_name Vote
extends Node
## collects vote from players. Automatically restart when all players have voted.

var _result: Dictionary[int, Variant]
var _last_result: Dictionary[int, Variant]


func get_current_vote() -> Dictionary[int, Variant]:
	return _result.duplicate()


func get_last_vote() -> Dictionary[int, Variant]:
	return _last_result.duplicate()


func reset() -> void:
	_last_result = _result.duplicate()
	_result.clear()

#-----------------------------------------------------------------#
signal voted(id: int)
signal vote_over(result)
var vote_max_count := Player.MAX_COUNT


func vote(value) -> void:
	_vote.rpc(Player.id, value)


@rpc("any_peer", "call_local")
func _vote(player_id: int, value) -> void:
	if player_id in _result:
		_debug_print("Vote Channel %s: Already voted locally" % name)
		return
	_result[player_id] = value
	_debug_print("Vote Channel %s: Player with %d voted for %s" % [name, player_id, value])
	voted.emit(player_id)
	if _result.size() == vote_max_count:
		reset()
		vote_over.emit()


func has_local_voted() -> bool:
	return Player.id in _result


func get_vote_count() -> int:
	return _result.size()


#-----------------------------------------------------------------#
func _init(p_name: String) -> void:
	name = p_name
	_debug_print("Vote Channel %s: Created >_<" % name)
	Network.instance.add_child(self)


var verbose_debug := true


func _debug_print(variant) -> void:
	if verbose_debug:
		Log.debug(variant)
