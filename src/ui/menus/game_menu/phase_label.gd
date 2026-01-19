extends Label

func _ready() -> void:
	Phase.manager.phase_changed.connect(_update_text)


func _update_text(p_phase: Phase) -> void:
	text = p_phase.name
