class_name ActionMove
extends ActionOperation

var _previous_coord: Vector2i


func _committed() -> bool:
	if not Game.instance.cursor.is_valid(true):
		return false

	_previous_coord = _ship.coord
	return _move_ship_to(Cursor.coord)


func _reverted() -> bool:
	if Player.fleet.has_ship_at(_previous_coord):
		_revert_failure_anim()
		return false
	return _move_ship_to(_previous_coord)


const TILE_TEXTURE: Texture = preload("uid://dh4opsme32878")
const REVERT_FAILURE_HINT_COLOR := Color.ORANGE_RED


func _revert_failure_anim():
	Anim.pop_up("OCCUPIED")
	var hint := Sprite2D.new()
	hint.texture = TILE_TEXTURE
	hint.modulate = REVERT_FAILURE_HINT_COLOR
	hint.position = Map.coord_to_pos(_previous_coord)
	Game.instance.add_child(hint)
	await Anim.fade_out(hint).finished
	hint.queue_free()


#-----------------------------------------------------------------#
func _move_ship_to(target: Vector2i) -> bool:
	if Player.fleet.has_ship_at(target):
		Anim.pop_up("OCCUPIED")
		return false
	if Player.fleet.move_ship_to(ship, target):
		return true
	return false
