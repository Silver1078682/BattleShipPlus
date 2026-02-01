@icon("uid://dt335t6vhyvxc")
class_name Component
extends MarginContainer

signal setting_changed()

@export var setting: Setting:
	set(p_setting):
		if not p_setting:
			push_error("Can not set setting to NIL")
			return
		if is_node_ready():
			push_error("Can not set setting on a Component that is ready")
		setting = p_setting

var value:
	get:
		return _value
	set(p_value):
		if typeof(_value) != typeof(p_value) or _value != p_value:
			if update_on_changed:
				update(p_value)
			_value = p_value

var _value

@export var update_on_changed := true


func update(p_value) -> void:
	SettingSaver.save_setting(setting, p_value)
	setting.apply(p_value)


func _ready() -> void:
	assert(setting)
	_value = SettingSaver.load_setting(setting)
	Setting.register_setting(setting)
	update(_value)
	_update_display()


func _update_display() -> void:
	pass
