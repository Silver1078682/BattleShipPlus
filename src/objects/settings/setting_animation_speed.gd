class_name SettingAnimationSpeed
extends Setting

func _apply(p_value: int) -> void:
	Anim.global_speed = p_value
