extends Control

func _auto_init():
	var categorized_settings: Dictionary[StringName, Array] = { }
	for setting: Setting in ResourceUtil.load_directory("settings"):
		if setting.section not in categorized_settings:
			categorized_settings[setting.section] = []
		categorized_settings[setting.section].append(setting)

	for i in categorized_settings:
		pass


func _ready() -> void:
	Log.debug("Setting Menu Ready")
