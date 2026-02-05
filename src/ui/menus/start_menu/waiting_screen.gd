class_name WaitingScreen
extends Control

@onready var title_label: Label = %TitleLabel


func setup(text: String) -> void:
	title_label.text = text
	show()


func _on_cancel_button_pressed() -> void:
	hide()
	if Network.is_server():
		Network.instance.terminate_server()
	else:
		Network.instance.terminate_client()
