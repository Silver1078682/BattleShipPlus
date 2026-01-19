class_name Sunk
extends VBoxContainer

var _sunk_ships: Dictionary[StringName, int]


func get_sunk_ship_count(type: StringName) -> int:
	var sunk_ship: int = _sunk_ships.get(type, 0)
	return sunk_ship


func get_sunk_ships() -> Dictionary[StringName, int]:
	return _sunk_ships.duplicate()


func add_sunk_ship(type: StringName) -> void:
	_sunk_ships[type] = _sunk_ships.get(type, 0) + 1
	var node_path := NodePath(String(type))
	if not has_node(node_path):
		_add_indicator(type)
	else:
		_get_indicator(type).count += 1


func remove_sunk_ship(type: StringName) -> void:
	if not type in _sunk_ships:
		Log.error("Sunk ship not found")
		return
	_sunk_ships[type] = _sunk_ships[type] - 1
	if _sunk_ships[type] < 0:
		_sunk_ships.erase(type)
		_remove_indicator(type)
	else:
		_get_indicator(type).count -= 1


#-----------------------------------------------------------------#
func _get_indicator(type: StringName) -> SunkShipIndicator:
	var indicator := get_node(String(type))
	assert(indicator is SunkShipIndicator)
	return indicator


func _add_indicator(type: StringName) -> SunkShipIndicator:
	var indicator = SUNK_SHIP_INDICATOR_SCENE.instantiate()
	indicator.name = type
	add_child(indicator)
	return indicator


func _remove_indicator(type: StringName) -> void:
	var indicator := get_node(String(type))
	assert(indicator is SunkShipIndicator)
	indicator.queue_free()


const SUNK_SHIP_INDICATOR_SCENE: PackedScene = preload("uid://qnfmogaswtht")
