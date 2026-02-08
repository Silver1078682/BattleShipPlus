class_name MapLayerMarker
extends Resource

@export var map_layer_layer: Map.Layer


#-----------------------------------------------------------------#
func start(_coord: Vector2i) -> void:
	mark(_coord)
	if should_update_on_cursor_changed():
		Game.instance.cursor.coord_changed.connect(mark)


func end() -> void:
	unmark()
	if should_update_on_cursor_changed():
		Game.instance.cursor.coord_changed.disconnect(mark)


func should_update_on_cursor_changed():
	return false


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


func get_coords() -> void:
	return


#-----------------------------------------------------------------#
func _get_map_layer() -> MapLayer:
	return Map.instance.get_layer(map_layer_layer)
