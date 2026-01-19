class_name Setting
extends Resource

@export var default: Variant
@export var name: String
@export var section: String
@export var description: String


func apply(p_value):
	_apply(p_value)
	Log.debug(self, " is applied")


func _apply(p_value):
	pass


static var settings: Dictionary[StringName, Variant]


static func get_value(name: StringName) -> Variant:
	return settings[name]


static func set_value(name: StringName, value: Variant) -> void:
	settings[name] = value


func _to_string() -> String:
	return "Setting [%s/%s %s(%s)]" % [section, name, Setting.get_value(name), default]
