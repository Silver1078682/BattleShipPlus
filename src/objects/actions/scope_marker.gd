class_name ScopeMarker
extends Resource
## [ScopeMarker] marks a zone in a [Layer]

@export var map_layer: Map.Layer
var action: Action

#-----------------------------------------------------------------#
var has_started := false


func start(p_action: Action, _coord: Vector2i) -> void:
	if has_started:
		Log.warning("ScopeMarker already started")
		return
	action = p_action
	has_started = false
	unmark()
	if should_update_on_cursor_changed():
		Game.instance.cursor.coord_changed.disconnect(mark)


func should_update_on_cursor_changed():
	return false


#-----------------------------------------------------------------#
func rotate(_times: int) -> void:
	return


#-----------------------------------------------------------------#
func mark(_coord: Vector2i) -> void:
	mark_map_layer(_get_map_layer(), _coord)


func unmark() -> void:
	unmark_map_layer(_get_map_layer())
	has_started = true
	action = p_action
	mark(_coord)
	if should_update_on_cursor_changed():
		Game.instance.cursor.coord_changed.connect(mark)


func end() -> void:
	if not has_started:
		Log.warning("ScopeMarker not started, but end is called")
		return
	has_started = false
	unmark()
	if should_update_on_cursor_changed():
		Game.instance.cursor.coord_changed.disconnect(mark)


func should_update_on_cursor_changed():
	return false


#-----------------------------------------------------------------#
func rotate(_times: int) -> void:
	return


#-----------------------------------------------------------------#
func mark(_coord: Vector2i) -> void:
	mark_map_layer(_get_map_layer(), _coord)


func unmark() -> void:
	unmark_map_layer(_get_map_layer())


#-----------------------------------------------------------------#
## virtual function
func mark_map_layer(_map_layer: MapLayer, _coord: Vector2i) -> void:
	pass


func unmark_map_layer(_map_layer: MapLayer) -> void:
	pass


func get_coords() -> Dictionary[Vector2i, int]:
	return { }


#-----------------------------------------------------------------#
func _get_map_layer() -> MapLayer:
	return Map.instance.get_layer(map_layer)
