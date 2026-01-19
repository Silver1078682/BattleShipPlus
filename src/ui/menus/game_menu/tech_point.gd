class_name TechPointBar
extends HBoxContainer

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var label: Label = %Label
const LABEL_FORMAT = "%d/%d"
var value: int:
	set(p_value):
		if progress_bar:
			progress_bar.value = p_value
		if label:
			label.text = LABEL_FORMAT % [p_value, max_value]
		value = p_value

var max_value: int:
	set(p_max_value):
		if progress_bar:
			progress_bar.max_value = p_max_value
		if label:
			label.text = LABEL_FORMAT % [value, p_max_value]
		max_value = p_max_value
