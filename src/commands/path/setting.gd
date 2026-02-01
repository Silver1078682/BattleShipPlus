extends Command

func _enter_tree() -> void:
	_add_command(_setting, "setting", "setting management")
	LimboConsole.add_argument_autocomplete_source("setting", 0, func(): return Setting.settings.keys())


#-----------------------------------------------------------------#
func _setting(option: String = "", value: Variant = null) -> void:
	if option == "":
		for setting_name in Setting.settings:
			LimboConsole.print_line(str(Setting.get_setting(setting_name)))
		return
	if value == null:
		LimboConsole.print_line(str(Setting.get_value(option)))
		return
	Setting.set_value(option, value)
