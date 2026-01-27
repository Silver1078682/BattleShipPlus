@tool
extends RefCounted

class_name SettingSaver

const _FILE_PATH: String = "user://settings.cfg"


## Saves the value of the given setting to the disc.
static func save_setting(setting: Setting, value) -> void:
	_config_file.set_value(setting.section, setting.name, value)
	_config_file.save(_FILE_PATH)


## Loads the value of the given setting from the disc.
static func load_setting(setting: Setting) -> Variant:
	return _config_file.get_value(setting.section, setting.name, setting.default)


static var _config_file: ConfigFile


static func _static_init() -> void:
	if _config_file:
		return

	var file: ConfigFile = ConfigFile.new()
	if FileAccess.file_exists(_FILE_PATH):
		file.load(_FILE_PATH)
	else:
		file.save(_FILE_PATH)
	_config_file = file
