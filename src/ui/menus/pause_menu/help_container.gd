extends Node

@export var format = "%s"
@export var input_spliter = "/"
#@onready var shortcut_label: Label = $Key

#@onready var input_label: Label = $Help
@onready var shortcut_label: Label = $Shortcut
@onready var input_label: Label = $Input


func _ready() -> void:
	var actions := InputMap.get_actions()

	for action_name in actions:
		if action_name.begins_with("ui_"):
			continue
		var action_events := InputMap.action_get_events(action_name)
		if not action_events:
			return

		if shortcut_label.text:
			shortcut_label.text += "\n"
			input_label.text += "\n"

		shortcut_label.text += action_name
		var packed_string := PackedStringArray(action_events.map(_event_to_string))
		input_label.text += input_spliter.join(packed_string)


func _event_to_string(event: InputEvent) -> String:
	var event_text := event.as_text()
	return event_text.trim_suffix("(Physical)")
