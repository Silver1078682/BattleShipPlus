class_name ActionLayMine
extends ActionOperation

#-----------------------------------------------------------------#
var _pre_mine_coord: Vector2i


func _committed() -> bool:
	if not Game.instance.cursor.is_valid(true):
		return false

	Phase.manager.phase_changed.connect(fade_and_leave_stage.unbind(1), CONNECT_ONE_SHOT)
	return _lay_mine_at(Cursor.coord)


func _reverted() -> bool:
	Phase.manager.phase_changed.disconnect(fade_and_leave_stage)
	return _remove_mine_at(_pre_mine_coord)


func fade_and_leave_stage() -> void:
	if not is_instance_valid(_ship):
		Log.warning("_ship not valid", " leave_stage not calling" if has_committed() else "")
	if has_committed():
		_ship.anim_process.tween_property(_ship, "modulate:a", 0, 1.0).finished.connect(_ship.leave_stage)
		# We can not do "await tweener.finished & _ship.leave_stage" because the Action will be freed
		# So the await process is aborted


#-----------------------------------------------------------------#
func _lay_mine_at(at: Vector2i) -> bool:
	_pre_mine_coord = at
	Player.mine.add_mine_at(at)
	return true


func _remove_mine_at(at: Vector2i) -> bool:
	Player.mine.remove_mine_at(at)
	return true
