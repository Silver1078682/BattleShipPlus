@tool
extends EditorScript

func _run() -> void:
	print("making pointing hand buttons")
	var roots := EditorInterface.get_open_scene_roots()
	for root in roots:
		var buttons := root.find_children("*", "Button")
		for button: Button in buttons:
			print(button)
			button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	print("Done! reopen every scene to take effect")
