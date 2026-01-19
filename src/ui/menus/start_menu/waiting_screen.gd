class_name WaitingScreen
extends Control

@onready var title_label: Label = %TitleLabel


func display(text: String) -> void:
	title_label.text = text
	show()
