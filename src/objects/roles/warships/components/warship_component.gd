@abstract class_name WarshipComponent
extends Node

@warning_ignore("unused_private_class_variable")
var _ship: Warship:
	get:
		return get_parent()
	set(p_ship):
		Log.warning("This is an read-only property")


func should_work():
	return (work_as_enemy and _ship.as_enemy) or (work_as_normal and not _ship.as_enemy)


var work_as_normal: bool
var work_as_enemy: bool
