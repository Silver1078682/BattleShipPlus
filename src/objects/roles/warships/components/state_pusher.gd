class_name WarshipStatePusher
extends WarshipComponent

func force_push(state: Dictionary[StringName, Variant]):
	Log.debug(_ship, "pushing state force: ", state)
	_ship.call_mirror(&"receive_state", state)


var _last: Dictionary[StringName, Variant] = { }


func push():
	var current = _ship.serialized()
	if current == _last:
		return
	_last = current
	Log.debug(_ship, "pushing state")
	_ship.call_mirror(&"receive_state", current)


func _to_string() -> String:
	return str("<<", _ship.config.abbreviation, _ship.id, ">:: WarshipPusher>")
