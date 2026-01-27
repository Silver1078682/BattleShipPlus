class_name Card
extends MarginContainer
## [Card] is a visual representation of an [Action] on the player's screen.
##
## Each Card represent an [Action] and its state.[br]
## As only one [Action] can be processed at the same time, only one [Card] can be selected at the same time.[br]
## [Card]s are managed by [CardManager]

static var manager: CardManager

#-----------------------------------------------------------------#
@export var action: Action:
	set(p_action):
		assert(not self.is_node_ready(), "Action can not be assigned to a card after it is ready")
		action = p_action

@export var button: Button

#-----------------------------------------------------------------#
## node pointers
@onready var name_label: Label = %Name
@onready var icon: TextureRect = %Icon
@onready var info_label: Label = %Info
@onready var amount_label: Label = %Amount
@onready var revert_icon: TextureRect = %Revert

#-----------------------------------------------------------------#
const _AMOUNT_LABEL_FORMAT := "%d/%d"


func update() -> void:
	_update()


func _update() -> void:
	if action.max_commit_times >= 0:
		var should_show_revert_icon := action.can_revert()
		revert_icon.visible = should_show_revert_icon

		amount_label.text = _AMOUNT_LABEL_FORMAT % [action.get_commit_times(), action.max_commit_times]
		#if action is ActionOperation  :
		#print(action._ship.action_terminator , action.has_reached_commit_limit())
		if action.has_reached_commit_limit() and not action.revertible:
			_make_disabled()
		else:
			_make_enabled()

	else:
		amount_label.hide()


func _make_enabled() -> void:
	button.disabled = false
	button.focus_mode = Control.FOCUS_ALL


func _make_disabled() -> void:
	button.disabled = true
	button.focus_mode = Control.FOCUS_NONE

#-----------------------------------------------------------------#
## emitted when selected
signal selected
## emitted when deselected
signal deselected

static var _selected_card: Card

## Only one [Card] can be selected at the same time.
## Deselect all [Card]s when value set null.
static var selected_card: Card:
	get:
		return _selected_card
	set(p_selected_card):
		if selected_card == p_selected_card:
			return
		_selected_card = null
		if selected_card:
			selected_card.deselected.emit()
		_selected_card = p_selected_card
		if p_selected_card:
			if (p_selected_card.button.get_focus_mode_with_override() != Control.FOCUS_ALL):
				Log.warning("Trying to select a Card ran out of use")
				_selected_card = null
				return
			p_selected_card.button.pressed.emit()
			p_selected_card.selected.emit()
			p_selected_card.button.grab_focus()

#-----------------------------------------------------------------#


## If the [Card] is selected [Card].
func is_selected() -> bool:
	return _selected_card == self


#-----------------------------------------------------------------#
func _ready() -> void:
	icon.texture = action.icon
	name_label.text = action.action_name
	info_label.text = action.description
	_set_up(action)

	button.pressed.connect(_on_button_pressed)


func _set_up(_action: Action) -> void:
	_action.committed.connect(_update)
	_action.reverted.connect(_update)
	_action.max_commit_times_changed.connect(_update)
	_update()


func _on_button_pressed() -> void:
	if action.has_reached_commit_limit():
		action.revert()
	else:
		action.start()


#-----------------------------------------------------------------#
func _unhandled_input(event: InputEvent) -> void:
	if not button.has_focus():
		return

	if action.input(event):
		return

	if event.is_action_pressed("confirm", false, true):
		action.commit()
	elif event.is_action_pressed("cancel", false, true):
		action.cancel()

#-----------------------------------------------------------------#
const CARD_SCENE := preload("uid://csdppykinmsuk")


## Returns a new instance of Card with the provided Action.
static func create_from_action(card_action: Action) -> Card:
	if not card_action:
		Log.error("creating Card from Action null")
		return null

	var card: Card = CARD_SCENE.instantiate()
	card.action = card_action
	return card
