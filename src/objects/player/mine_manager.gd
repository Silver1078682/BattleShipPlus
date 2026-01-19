class_name MineManager
extends Node2D

var mines: Dictionary[Vector2i, Mine]
var _staged_additions: Dictionary[Vector2i, Mine]
var _staged_removals: Dictionary[Vector2i, Mine]

@export var visible_on_default := true


#-----------------------------------------------------------------#
func get_mine(coord: Vector2i) -> Mine:
	return mines[coord]


const MINE_SCENE = preload("uid://dlj8823ennbg")


func add_mine_at(at: Vector2i, as_mirror := false) -> void:
	if has_mine_at(at):
		Log.error("Trying to add a mine at ", at, ", but there is already a mine here.")
		return

	var mine: Mine = MINE_SCENE.instantiate()
	mine.coord = at
	mine.visible = visible_on_default

	NodeUtil.set_parent_of(mine, self)
	if not as_mirror:
		_staged_additions[at] = mine
		_staged_removals.erase(at)
	mines[at] = mine

	Log.debug("mine ", mine, " added")


func has_mine_at(coord: Vector2i) -> bool:
	return coord in mines


#-----------------------------------------------------------------#
func remove_mine(mine: Mine) -> void:
	remove_mine_at(mine.coord)


func remove_mine_at(coord: Vector2i, as_mirror := false) -> void:
	if not coord in mines:
		Log.error("Trying to remove a non-existent mine at %s" % coord)
		return

	var mine := mines[coord]
	if not as_mirror:
		if coord in _staged_additions:
			_staged_additions.erase(coord)
		else:
			_staged_removals[coord] = mine

	mine.queue_free()
	mines.erase(coord)


#-----------------------------------------------------------------#
## Push the changes of mine to the remote peer.
func push_mines() -> void:
	if _staged_additions or _staged_removals:
		Network.instance.rpc_call(^"Opponent/Mine", &"update_mine", _staged_additions.keys(), _staged_removals.keys())
	_staged_additions.clear()
	_staged_removals.clear()


## Add all mines in mine_added to the local mine list.
## Remove all mines in mine_deleted from the local mine list.
func update_mine(mine_added: Array[Vector2i], mine_deleted: Array[Vector2i]) -> void:
	for coord in mine_added:
		add_mine_at(coord, true)
	for coord in mine_deleted:
		remove_mine_at(coord, true)
