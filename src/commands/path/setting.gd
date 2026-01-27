extends Command

func _enter_tree() -> void:
	_add_command(_setting, "setting", "setting management")


#-----------------------------------------------------------------#
func _setting(option: String = "", value: Variant = null):
	if option == "":
		for setting_name in Setting.settings:
			LimboConsole.print_line(setting_name + " " + str(Setting.settings[setting_name]))
		return
	if value == null:
		LimboConsole.print_line(Setting.get_value(option))
		return
