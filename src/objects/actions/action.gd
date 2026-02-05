class_name Action
extends Resource
## [Action] is a single "move" that a player can perform during a game phase.
## For example, moving a warship or take an attack.
##
## [b]life cycle of an Action:[/b][br]
## Started: When a player selects an [Action] from their hand.[br]
## Committed: When a player decided to take this [Action].[br]
## Cancelled: When a player gives up taking this [Action].[br]
## Reverted: When a player reverts an [Action] (if the [Action] can be reverted).[br]
## Exited: When a player exit this phase, each existing [Action] will be exited.[br]
## [br]
##
## [b]Display:[/b][br]
## The corresponding visual node for displaying an [Action] on a player's screen is a [Card].
## See [Card] for more details.

#-----------------------------------------------------------------#
# The action being process
static var _action_in_process: Action:
	set(p_action_in_process):
		if _action_in_process != p_action_in_process:
			_change_scope_marker_object(_action_in_process, p_action_in_process)
			_change_cursor_check_object(_action_in_process, p_action_in_process)
			_action_in_process = p_action_in_process


## Returns the current action being processed or null if there is none.
static func get_action_in_process() -> Action:
	return _action_in_process


## Returns if there is an action being processed or not
static func has_action_in_process() -> bool:
	return _action_in_process != null


#-----------------------------------------------------------------#
## Start the action (Called when Action Card is clicked by default)
func start() -> void:
	if has_reached_commit_limit():
		return
	_action_in_process = self
	mark_scope()
	_started()


## Behaviors when action card is clicked, see [method start]
func _started() -> void:
	pass

#-----------------------------------------------------------------#
@export_group("area")
## The [Area] only in which the [Action] can be committed.
@export var action_area: Area
## If set true, the center of [member action_area] will follow player's mouse.
@export var follow_mouse := false
## If set true, [_update_area_on_cursor_coord_changed] will be called when the cursor coordinate changes.
@export var area_force_mouse_update := false


func should_update_area_on_cursor_coord_changed() -> bool:
	return follow_mouse or area_force_mouse_update


## mark the [Area] of the [Action] in the [Map].
func mark_scope() -> void:
	var coord := Cursor.coord if follow_mouse else Vector2i.ZERO
	if action_area:
		action_area.offset = coord
	Map.instance.scope.set_dict(_get_action_area())


# proxy function
func _get_action_area() -> Dictionary[Vector2i, int]:
	if not action_area:
		return { }
	return action_area.get_coords()


static func _change_scope_marker_object(previous_action: Action, new_action: Action) -> void:
	var cursor = Game.instance.cursor
	if previous_action and previous_action.should_update_area_on_cursor_coord_changed():
		cursor.coord_changed.disconnect(previous_action.mark_scope.unbind(1))
	if new_action and new_action.should_update_area_on_cursor_coord_changed():
		cursor.coord_changed.connect(new_action.mark_scope.unbind(1))

#-----------------------------------------------------------------#
@export_group("commit_and_revert")

signal max_commit_times_changed
## Maximum times an action can be committed.
## There is no limit when the value set negative.
## Set it zero result in an action that can not be committed
@export var max_commit_times := 1:
	set(p_max_commit_times):
		if max_commit_times != p_max_commit_times:
			max_commit_times = p_max_commit_times
			max_commit_times_changed.emit()

## How many times has the [Action] been committed so far
var _commit_times := 0


## Returns the number of times this action has been committed.
## NOTE: This value will reduce when the [Action] is reverted.
func get_commit_times() -> int:
	return _commit_times


## Returns if this action has been committed at least once.
func has_committed() -> bool:
	return _commit_times > 0


## Returns if this action has reached the commit limit.
func has_reached_commit_limit() -> bool:
	return _commit_times >= max_commit_times and max_commit_times >= 0

#-----------------------------------------------------------------#
## Emitted when the Action is committed
signal committed


## Commit the action.
## See [method _committed].
func commit() -> void:
	if has_reached_commit_limit():
		return

	if _committed():
		Log.debug("Action %s committed" % self)
		_commit_times += 1

		if has_reached_commit_limit():
			_action_in_process = null
			cancel()

		committed.emit()

	elif cancel_on_failure:
		cancel()


## Custom behavior when the [Action] is committed.
## Should return whether the commit is successful
func _committed() -> bool:
	return false

#-----------------------------------------------------------------#
## Emitted when the Action is committed
signal reverted
## If the action is able to be reverted
@export var revertible := true


## Return whether this action can be reverted [b]now[/b].
## i.e. revertible set true and has at least one commit.
func can_revert() -> bool:
	return has_committed() and revertible


## Revert the action.
## See [method can_revert] and [method _reverted].
func revert() -> void:
	if can_revert():
		if _reverted():
			Log.debug("Action %s reverted" % self)
			_commit_times -= 1

			reverted.emit()
			Map.instance.scope.clear_mask()


## Custom behavior when reverting an action.
## Should return whether the revert is successful
func _reverted() -> bool:
	return false

#-----------------------------------------------------------------#
## If set true, [Action] will be automatically cancelled
## when action has failed to commit
@export var cancel_on_failure := true
## Emitted when action is cancelled
signal cancelled


## Cancel the action.
## See [method _cancelled]
func cancel() -> void:
	cancelled.emit()
	_action_in_process = null
	_cancelled()


## Behavior when an [Action] is cancelled
func _cancelled() -> void:
	Map.instance.scope.clear_mask()


#-----------------------------------------------------------------#
## Called on each [Card] with this type of [Action] when it is exiting the current [Phase]
func exit() -> void:
	_exited()


## Behavior when an [Action] Card of this type
func _exited() -> void:
	pass


#-----------------------------------------------------------------#
## Input handler interface
func input(event: InputEvent) -> bool:
	return _input(event)


## Custom input handler, should returns true if the input has been handled
func _input(event: InputEvent) -> bool:
	if action_area:
		if event.is_action_pressed("rotate_forward"):
			action_area.rotate(1)
			mark_scope()
		if event.is_action_pressed("rotate_backward"):
			action_area.rotate(-1)
			mark_scope()
	return false

#-----------------------------------------------------------------#
@export var check_cursor_fleet := true
@export var check_cursor_mine := true


## Check if the coordinate is a valid place to commit the action.
## See [method _get_cursor_check_list] for more details.
func check_cursor(p_coord: Vector2i) -> void:
	var cursor = Game.instance.cursor
	cursor.invalid_check.clear()
	var check_list := _get_cursor_check_list(p_coord)
	for rule in check_list:
		cursor.check_if_valid(check_list[rule], rule)
	_update_cursor(p_coord, cursor)


## Get the list of rules to check for the cursor position.
## See the default example below for more details.
func _get_cursor_check_list(p_coord: Vector2i) -> Dictionary[String, bool]:
	var map := Map.instance
	return {
		"CANNOT_MOVE_HERE": map.scope.has_coord(p_coord),
		"NOT_IN_MAP": map.has_coord(p_coord),
		"OCCUPIED": not Player.fleet.has_ship_at(p_coord) or not check_cursor_fleet,
		"OCCUPIED_BY_MINE": not Player.mine.has_mine_at(p_coord) or not check_cursor_mine,
		"CANNOT_ARRANGE_BASE": p_coord != map.get_base().coord,
	}


## Custom behaviors on cursor's coordinate changed.
## Only works when [member area_force_mouse_update] set true.
func _update_cursor(_p_coord: Vector2i, _cursor: Cursor) -> void:
	pass


static func _change_cursor_check_object(previous_action: Action, new_action: Action) -> void:
	var cursor = Game.instance.cursor
	if previous_action:
		cursor.coord_changed.disconnect(previous_action.check_cursor)
	if new_action:
		cursor.coord_changed.connect(new_action.check_cursor)

#-----------------------------------------------------------------#
@export_group("Display")
@export var action_name := "Action":
	get = _get_action_name
## Icon for this [Action].
@export var icon: Texture = null:
	get = _get_icon
## Description of this [Action].
@export var description: String:
	get = _get_description


func _get_action_name() -> String:
	return action_name


func _get_icon() -> Texture:
	return icon


func _get_description() -> String:
	return description


#-----------------------------------------------------------------#
func _init() -> void:
	resource_local_to_scene = true


const _TO_STRING_FORMAT = "{%s %%s %04d}"


func _to_string() -> String:
	return _TO_STRING_FORMAT % [action_name, abs(get_instance_id() % 10000)]
