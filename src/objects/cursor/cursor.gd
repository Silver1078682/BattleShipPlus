class_name Cursor
extends Node2D
## The mouse cursor
##
## Do 2 things:
## 1. record the cursor's coord
## 2. keep track why an operation cannot be operated at certain coordinate
##    Sometimes the reason might have nothing to do with the coordinate itself
##    See [check_if_valid]

# node pointers
## This Node snapped to map coordinate
@onready var snapped_cursor: Node2D = $"../SnappedCursor"
@onready var invalid_tile: Sprite2D = $"../SnappedCursor/InvalidTile"

signal coord_changed(p_coord: Vector2i)
static var coord: Vector2i:
	get:
		return _coord
	set(p_coord):
		if _coord != p_coord:
			_coord = p_coord
			Game.instance.cursor.coord_changed.emit(p_coord)

static var _coord: Vector2i

#-----------------------------------------------------------------#
var invalid_check: Dictionary


## Check if the cursor is at a valid position, If pop_reason is true,
## pop up the reason of why it's invalid. Only the last reason added will be pop up
func is_valid(pop_reason := false) -> bool:
	if pop_reason and invalid_check:
		Anim.pop_up(invalid_check.keys()[-1])
	return invalid_check.is_empty()


func check_if_valid(check_passed: bool, reason: String) -> void:
	if not check_passed:
		invalid_check[reason] = null
	else:
		invalid_check.erase(reason)
	invalid_tile.visible = not is_valid()


func clear() -> void:
	invalid_check.clear()


#-----------------------------------------------------------------#
func _ready() -> void:
	Phase.manager.phase_changed.connect(clear.unbind(1))
	coord_changed.connect(_on_coord_changed)


func _process(_delta: float) -> void:
	if not Map.instance:
		return
	position = get_global_mouse_position()
	coord = Map.pos_to_coord(position)


func _on_coord_changed(p_coord: Vector2i) -> void:
	snapped_cursor.position = Map.coord_to_pos(p_coord)
	check_if_valid(Game.instance.map.has_coord(p_coord), "NOT_IN_MAP")
