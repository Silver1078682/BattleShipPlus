class_name AdvancedComponent
extends Component

@onready var label := %Label
@export var auto_set_text := true


func set_value(p_value):
	value = p_value


func _on_setting_changed() -> void:
	if auto_set_text:
		label.text = setting.name
	tooltip_text = setting.description


func _ready() -> void:
	super()
	if auto_set_text:
		label.text = setting.name
	tooltip_text = setting.description
