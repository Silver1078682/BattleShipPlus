class_name MirrorRequest
extends Node

func _get_or_create_mirror(serialized_warship: Dictionary[StringName, Variant]) -> Warship:
	var mirror_name := "Warship" + str(serialized_warship.id)
	var mirror: Warship = Opponent.fleet.get_node_or_null(mirror_name)
	if not mirror:
		mirror = _create_mirror_ship(serialized_warship)
	return mirror


func _create_mirror_ship(serialized_warship: Dictionary[StringName, Variant]) -> Warship:
	var warship := Warship.create_from_name(serialized_warship.config)
	if not warship:
		Log.error("a warship failed to be deserialized")

	warship.deserialized(serialized_warship)
	Opponent.fleet.add_ship(warship, false)
	_on_remote_mirror_created.rpc(warship.id)
	return warship


# Create multiple mirror ships from a serialized dictionary of ships.
func create_mirrors_from_list(serialized_warships: Dictionary, highlight := true) -> void:
	for coord in serialized_warships:
		var serialized_warship: Dictionary[StringName, Variant]
		serialized_warship.assign(serialized_warships[coord])
		var warship := _get_or_create_mirror(serialized_warship)
		if highlight:
			_highlight_mirror_ship(warship)


func _highlight_mirror_ship(warship: Warship) -> void:
	warship.is_highlighted = true
	Opponent.fleet.warships_just_hit.append(warship)


#-----------------------------------------------------------------#
@rpc("any_peer", "call_remote", "reliable")
func _on_remote_mirror_created(warship_id: int) -> void:
	var local_name := "Warship" + str(warship_id)
	var local: Warship = Player.fleet.get_node_or_null(local_name)
	if not local:
		Log.error("remote mirror of Warship%d is created but local instance can not be found" % warship_id)
		return
	local.has_mirror = true
