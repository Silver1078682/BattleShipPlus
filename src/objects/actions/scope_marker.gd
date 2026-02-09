class_name ScopeMarker
extends Resource
## [ScopeMarker] marks a zone in a [Layer]
##
## An [ScopeMarker] can be complicated. for instance, it may react to user's input, and change dynamically
## call [method.start] and [method.end] to make it work

@export var map_layer: Map.Layer
var action: Action

#-----------------------------------------------------------------#
var offset: Vector2i
var _has_started := false


func has_started() -> bool:
	return _has_started


func start(p_action: Action, p_offset: Vector2i) -> void:
	if _has_started:
		Log.warning("ScopeMarker already started")
		return
	action = p_action
	offset = p_offset
	_has_started = true
	mark()
	if should_update_on_cursor_changed():
		Game.instance.cursor.coord_changed.connect(mark.unbind(1))


func stop() -> void:
	if not _has_started:
		Log.warning("ScopeMarker not started, but stop is called")
		return
	_has_started = false
	unmark()
	if should_update_on_cursor_changed():
		Game.instance.cursor.coord_changed.disconnect(mark.unbind(1))


func should_update_on_cursor_changed():
	return false


#-----------------------------------------------------------------#
func input(event: InputEvent) -> void:
	_input(event)


func _input(_event: InputEvent) -> void:
	pass


#-----------------------------------------------------------------#
func mark() -> void:
	_mark_map_layer(_get_map_layer())


func unmark() -> void:
	_unmark_map_layer(_get_map_layer())


#-----------------------------------------------------------------#
## virtual function
func _mark_map_layer(_map_layer: MapLayer) -> void:
	pass


func _unmark_map_layer(_map_layer: MapLayer) -> void:
	pass


func get_coords() -> Dictionary[Vector2i, int]:
	return { }


#-----------------------------------------------------------------#
func _get_map_layer() -> MapLayer:
	return Map.instance.get_layer(map_layer)
