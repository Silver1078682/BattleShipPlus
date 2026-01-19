class_name SettingWindowMode
extends Setting

func _apply(p_value: bool) -> void:
	var window_mode: Window.Mode = Window.MODE_FULLSCREEN if p_value else Window.MODE_WINDOWED
	if Main.instance:
		Main.instance.get_window().mode = window_mode
