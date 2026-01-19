class_name EndingScreen
extends PanelContainer

@onready var result_label: Label = %ResultLabel
@onready var end_condition_label: Label = %EndConditionLabel

const RESULT_MESSAGES := ["FAILURE", "DRAW", "SUCCESS"]
const END_CONDITION_MESSAGES := ["NONE", "NO_VALID_SHIP", "ENEMY_AT_UNPROTECTED_HOME"]


func display(result: Game.Result, end_screen: Game.EndCondition):
	_display(RESULT_MESSAGES[result], END_CONDITION_MESSAGES[end_screen])


func _display(result_message: String, end_condition_message: String):
	result_label.text = result_message
	end_condition_label.text = end_condition_message
	show()
