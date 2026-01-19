extends Container

@onready var _ship: Warship = get_parent()


func _ready() -> void:
	if _ship.as_enemy:
		hide()


func set_torpedo(p_torpedo: int) -> void:
	value = p_torpedo

#-----------------------------------------------------------------#
@export var value: int:
	set(p_value):
		value = p_value
		_set_icon_amount(p_value)


func _set_icon_amount(amount: int) -> void:
	var idx := -1
	var count := get_child_count()

	for i in amount:
		idx += 1
		if idx >= count:
			var new_icon := get_child(0).duplicate()
			add_child(new_icon)
		else:
			var existing_icon: Node = get_child(idx)
			existing_icon.show()

	if count > idx:
		for surplus_idx in range(idx + 1, count):
			var surplus_icon: Node = get_child(surplus_idx)
			surplus_icon.hide()
