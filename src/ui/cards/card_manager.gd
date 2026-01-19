class_name CardManager
extends Node

## The actual container that holds all Cards
@export var container: Container
## Tech point
@export var tech_point: TechPointBar


#-----------------------------------------------------------------#
func get_card(idx: int) -> Card:
	if idx >= container.get_child_count():
		return null
	var card := container.get_child(idx)
	assert(card is Card)
	return card


func get_cards() -> Array[Card]:
	var cards: Array[Card] = []
	cards.assign(container.get_children())
	return cards


func get_card_count() -> int:
	return container.get_child_count()


func is_empty() -> bool:
	return container.get_child_count() == 0


#-----------------------------------------------------------------#
func add_card(card: Card) -> void:
	container.add_child(card)
	var action := card.action
	# lose focus on cancelled
	if not action.cancelled.is_connected(UI.lose_focus):
		action.cancelled.connect(UI.lose_focus)
	# disable all other Card for terminating Action
	if action is ActionOperation and action.is_terminating:
		if action.committed.is_connected(_update_all):
			action.committed.connect(_update_all)
			action.reverted.connect(_update_all)


#-----------------------------------------------------------------#
func remove_card(idx: int) -> void:
	var card := get_card(idx)
	if not card:
		return

	var current_action := Action.get_action_in_process()
	if card.action == current_action:
		card.action.cancel()

	card.queue_free()


func clear() -> void:
	var current_action := Action.get_action_in_process()
	if current_action:
		current_action.cancel()

	for card: Card in get_cards():
		if card.action:
			card.action.exit()
		card.queue_free()


func _update_all():
	for card in get_cards():
		card.update()


#-----------------------------------------------------------------#
func _init() -> void:
	Card.manager = self


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel_all", false, true):
		for card in get_cards():
			card.action.cancel()
