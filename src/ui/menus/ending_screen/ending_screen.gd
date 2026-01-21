class_name EndingScreen
extends Control

@onready var result_label: Label = %ResultLabel
@onready var end_condition_label: Label = %EndConditionLabel

const RESULT_MESSAGES := ["FAILURE", "DRAW", "SUCCESS"]


func display(result: Game.Result, end_screen: Game.EndCondition):
	_display(RESULT_MESSAGES[result], Game.END_CONDITION_ARRAY[end_screen])


func _display(result_message: String, end_condition_message: String):
	result_label.text = result_message
	end_condition_label.text = end_condition_message
	show()


func _on_back_button_pressed() -> void:
	if Network.is_client():
		Network.instance.terminate_client()
	if Network.is_server():
		Network.instance.terminate_server()
	Main.instance.back_to_main_menu()
