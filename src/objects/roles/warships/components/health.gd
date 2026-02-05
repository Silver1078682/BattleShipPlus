class_name WarshipHealth
extends WarshipComponent

signal changed(p_health: int)
signal death
var value: int:
	set(p_value):
		if value != p_value:
			changed.emit(p_value)
			value = p_value
			if p_value <= 0:
				death.emit()
