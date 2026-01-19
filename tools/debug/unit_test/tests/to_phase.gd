extends Tester

@export var to_phase: StringName = &"AerialDefense"
@export_range(1, 10, 1, "or_greater") var max_auto_try := 10
@export var wait_interval := 1.0


func _run() -> void:
	if Network.is_server():
		for i in max_auto_try:
			await Anim.sleep(wait_interval)
			if Phase.manager.get_phase().name == to_phase:
				break
			Phase.manager.next_phase_or_turn()
