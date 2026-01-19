@tool
class_name SettingOption
extends Node

const _WARNING_WRONG_PARENT_TYPE := "The parent of a SettingOption should be Setting"


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	if get_parent() is not Setting:
		warnings.append(_WARNING_WRONG_PARENT_TYPE)
	return warnings
