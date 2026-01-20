extends Label

const DEBUG_HINT = "(debug)"


func _ready() -> void:
	text = ProjectSettings.get_setting("application/config/version")
	if OS.is_debug_build():
		text += DEBUG_HINT
