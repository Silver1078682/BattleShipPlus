extends HBoxContainer

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var idx: int = event.keycode - KEY_1
		if 0 <= idx and idx < get_child_count():
			Card.selected_card = (get_child(idx) as Card)
