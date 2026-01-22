extends Label

const DEBUG_HINT = "debug"
const DEBUG_BUILD = "build"


func _ready() -> void:
	text = ProjectSettings.get_setting("application/config/version")
	var hint := []

	if OS.is_debug_build():
		hint.append(DEBUG_HINT)
	if OS.has_feature("template"):
		hint.append(DEBUG_BUILD)

	if hint:
		text += "(%s)" % " ".join(hint)
