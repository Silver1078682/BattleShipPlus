class_name ScopeMarker
extends Resource

@export var scope_layer: Scope.Layer


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
	mark_scope(_get_scope(), _coord)


func unmark() -> void:
	unmark_scope(_get_scope())


#-----------------------------------------------------------------#
## virtual function
func mark_scope(_scope: Scope, _coord: Vector2i) -> void:
	pass


func unmark_scope(_scope: Scope) -> void:
	pass


func get_coords() -> void:
	return


#-----------------------------------------------------------------#
func _get_scope() -> Scope:
	return Map.instance.get_scope(scope_layer)
