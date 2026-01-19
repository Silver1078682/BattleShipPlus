class_name UI
extends Control

@onready var card_deck: VBoxContainer = %CardDeck
@onready var sunk: HBoxContainer = %Sunk
@onready var ending_screen: EndingScreen = %EndingScreen


#-----------------------------------------------------------------#
static func lose_focus() -> void:
	instance.grab_focus()

#-----------------------------------------------------------------#
static var instance: UI


func _init() -> void:
	assert(not instance, "singleton instance initialized")
	instance = self
	Log.debug("UI instance initialized")


#-----------------------------------------------------------------#
func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	focus_behavior_recursive = Control.FOCUS_BEHAVIOR_ENABLED
	Log.debug("UI instance ready")


func setup() -> void:
	Log.info("UI instance setup")
	_setup()


func _setup() -> void:
	pass
