# class_name NextPhaseButton
extends Button

@onready var count_label: Label = $Count


#-----------------------------------------------------------------#
func _ready() -> void:
	count_label.text = _COUNT_LABEL_FORMAT % [0, 2]
	Game.instance.readiness_confirmation.voted.connect(_update_count_label.unbind(1))
	for turn_or_phase_changed in [Phase.manager.turn_changed, Phase.manager.phase_changed]:
		turn_or_phase_changed.connect(_update_count_label.unbind(1))
		turn_or_phase_changed.connect(_update_enabled.unbind(1))


func _on_pressed() -> void:
	_notify_ready()


func _shortcut_input(event: InputEvent) -> void:
	if event.is_action("next_phase"):
		_notify_ready()

#-----------------------------------------------------------------#
func _notify_ready() -> void:
	await Anim.wait_anim()
	if Game.instance.readiness_confirmation.has_local_voted():
		return

	make_disabled()
	Game.instance.readiness_confirmation.vote(true)

#-----------------------------------------------------------------#
const _COUNT_LABEL_FORMAT := "%d/ %d"


func _update_count_label() -> void:
	if Game.instance.readiness_confirmation.has_local_voted():
		tooltip_text = "READINESS_ALREADY_CONFIRMED"
	elif not Phase.manager.is_turn_of(Player.id):
		tooltip_text = "NOT_YOUR_TURN"
	else:
		tooltip_text = "CLICK_TO_CONFIRM_READINESS"
	count_label.text = _COUNT_LABEL_FORMAT % [
		Game.instance.readiness_confirmation.get_vote_count(),
		Game.instance.get_required_ready_player_count(),
	]


func _update_enabled() -> void:
	disabled = not Phase.manager.is_turn_of(Player.id)


#-----------------------------------------------------------------#
func make_enabled() -> void:
	disabled = false


func make_disabled() -> void:
	disabled = true
