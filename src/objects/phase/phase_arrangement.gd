class_name PhaseArrangement
extends Phase

const ACTION_ARRANGE: ActionArrange = preload("uid://cdtoumymcr6xd")


func _enter() -> void:
	Log.debug("Creating arrange cards ...")

	for warship_name in ActionArrange.INITIAL_ARRANGE:
		var card := Card.create_from_action(ACTION_ARRANGE.duplicate(true))
		var warship_config := Warship.get_config(warship_name)
		card.action.warship_config = warship_config

		Card.manager.add_card(card)

	Log.debug("Arrange cards created")
