class_name PhaseAerialDefense
extends Phase

func _exit() -> void:
	_reset_effect_duration_count_down()
	Phase.manager.phase_changed.connect(_effect_duration_count_down.unbind(1))


@export var effect_duration := 1


func _effect_duration_count_down() -> void:
	_effect_duration_counter -= 1

	if _effect_duration_counter <= 0:
		_timeout()
		_reset_effect_duration_count_down()
		Phase.manager.phase_changed.disconnect(_effect_duration_count_down)


func _reset_effect_duration_count_down() -> void:
	_effect_duration_counter = effect_duration + 1
	if effect_duration < 0:
		Log.warning("effect_duration is set negative")
		_effect_duration_counter = 1


var _effect_duration_counter := 0


func _timeout() -> void:
	Log.info("%s preserve time out" % self)
	Map.instance.aerial_defense_layer.clear_mask()
	ActionAerialDefense.clear_aerial_defense_areas()
