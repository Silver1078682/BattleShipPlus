class_name Setting
extends Resource
## A setting of the game.
##
## _applied will be called when the setting is applied.

## The default value of a [Setting]
@export var default: Variant
## The name of a [Setting]
@export var name: String
## The current value of a [Setting].
## changing this value alone will not make any changes to the game.
## Use [method apply] instead
@export var value: Variant
## The section of the [Setting] to be saved
@export var section: String
## The description of the [Setting]
@export var description: String

signal setting_changed


## Apply the setting to a new value.
func apply(p_value):
	value = p_value
	_apply(p_value)
	Log.debug(self, " is applied")


## Virtual function that is called when the setting is applied.
func _apply(_p_value):
	pass

#-----------------------------------------------------------------#
static var settings: Dictionary[StringName, Setting]


static func get_value(name: StringName) -> Variant:
	return settings[name].value if (name in settings) else null


static func set_value(name: StringName, p_value: Variant) -> void:
	if name in settings:
		settings[name].apply(p_value)
	else:
		Log.error("Setting ", name, " not found")


static func get_setting(name: StringName) -> Setting:
	return settings.get(name)


static func register_setting(setting: Setting) -> void:
	settings[setting.name] = setting


static func unregister_setting(name: StringName) -> void:
	settings.erase(name)

#-----------------------------------------------------------------#


func _to_string() -> String:
	return "Setting [%s/%s %s(%s)]" % [section, name, Setting.get_value(name), default]
