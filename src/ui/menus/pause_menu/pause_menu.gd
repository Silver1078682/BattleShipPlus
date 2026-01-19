extends Control

@onready var info_label: Label = %InfoLabel


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("help"):
		visible = not visible
		if visible:
			info_label.update_text()
	elif visible and event.is_action("ui_cancel"):
		visible = false
