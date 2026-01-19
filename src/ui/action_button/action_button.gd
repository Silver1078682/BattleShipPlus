class_name ActionButton
extends TextureButton
## An Button displayed on warships.
##
## An [ActionButton] will display all [Action]s available in current [Phase]
## from corresponding [Warship] as [Card]s on pressed.
## If the [Warship] does not have any [Action]s available, it will be deactivated and hidden.

#-----------------------------------------------------------------#
## An button can be activated or deactivated.
## An button is only visible when it's activate
signal activated
var is_activated := false:
	set(p_is_activated):
		if p_is_activated != is_activated:
			if p_is_activated:
				_activated()
			else:
				_deactivated()
			activated.emit()
			is_activated = p_is_activated


# WARNING Don't use internally
## Interface for activating the button.
## Equivalent to setting is_activated true
func activate() -> void:
	is_activated = true


## Interface for deactivating the button.
## Equivalent to setting is_activated false
func deactivate() -> void:
	_revert_mode = false
	is_activated = false


func _activated() -> void:
	show()


func _deactivated() -> void:
	hide()

#-----------------------------------------------------------------#
## emitted when selected
signal selected
## emitted when deselected
signal deselected
static var _selected_button: ActionButton

## A button can be only selected when it's activated.
## Only one button can be selected at the same time.
## Deselect all buttons when value set null.
static var selected_button: ActionButton:
	get:
		return _selected_button
	set(p_selected_button):
		if selected_button == p_selected_button:
			return
		_selected_button = null
		if selected_button:
			selected_button.deselected.emit()
		_selected_button = p_selected_button
		if p_selected_button:
			p_selected_button.selected.emit()


## If the button is selected button.
func is_selected() -> bool:
	return _selected_button == self

#-----------------------------------------------------------------#
const ACTION_COLOR := Color.POWDER_BLUE
const SELECTED_ACTION_COLOR := Color.MEDIUM_SPRING_GREEN
const REVERT_COLOR := Color.DARK_KHAKI
const SELECTED_REVERT_COLOR := Color.DARK_ORANGE

# only be set true when
# 1. The warship has only one action in this phase
# 2. The action has been committed and the action is indeed revertible
var _revert_mode := false


func _check_action(action: Action) -> void:
	_revert_mode = action.can_revert()
	_update_color(is_selected())


# highlight the button based on its state.
func _update_color(p_selected: bool) -> void:
	if _revert_mode:
		if p_selected:
			modulate = SELECTED_REVERT_COLOR
		else:
			modulate = REVERT_COLOR
	else:
		if p_selected:
			modulate = SELECTED_ACTION_COLOR
		else:
			modulate = ACTION_COLOR


#-----------------------------------------------------------------#
func _get_warship() -> Warship:
	return get_parent()


#-----------------------------------------------------------------#
func reset() -> void:
	deactivate()
	_update_color(is_selected())


#-----------------------------------------------------------------#
func _ready() -> void:
	pressed.connect(_on_pressed)
	_update_color(false)


func _on_pressed() -> void:
	Card.manager.clear()

	var warship := _get_warship()
	if not warship.get_actions():
		Anim.pop_up("No actions available.") # This shouldn't happen anyway
		return

	var actions := warship.get_actions()
	var first_action := actions[0]

	# Display the action state if there's only one action
	if actions.size() == 1:
		if not first_action.committed.is_connected(_check_action):
			first_action.committed.connect(_check_action.bind(first_action))
			first_action.reverted.connect(_check_action.bind(first_action))

	var first_card: Card = null
	for action in actions:
		var card := Card.create_from_action(action)
		if not first_card:
			first_card = card
		Card.manager.add_card(card)

	if not first_card:
		return
	# Select the first card automatically.
	if not first_card.action.has_reached_commit_limit():
		Card.selected_card = first_card
	elif _revert_mode and first_card.action.can_revert():
		first_card.action.revert()
		Card.selected_card = first_card

	selected_button = self
