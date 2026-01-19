extends AdvancedComponent

@export var options: Array[String]
@onready var option_button: OptionButton = %OptionButton


func _update_option_button() -> void:
	for i in options.size():
		option_button.add_item(options[i], i)


func _on_index_selected(idx: int) -> void:
	value = options.get(idx)


func _ready() -> void:
	_update_option_button()
	super()


func _update_display() -> void:
	var index := options.find(_value)
	option_button.select(index)
