class_name MapSelectorOption
extends MarginContainer

@onready var button: Button = %Button
@onready var sub_viewport: SubViewport = %SubViewport
@onready var label: Label = %Label
const MapDisplayCamera = preload("uid://bwohslg7a3tv0")

var map_scene: PackedScene:
	set(p_map_scene):
		if map_scene != p_map_scene:
			if p_map_scene:
				map = p_map_scene.instantiate()
			map_scene = p_map_scene

var map: Map:
	set(p_map):
		if is_node_ready() and p_map:
			_load_map(p_map)
		map = p_map

signal selected


func _on_button_pressed() -> void:
	Map.instance = map
	selected.emit()


func _ready() -> void:
	_load_map(map)


func _load_map(p_map: Map):
	if not p_map:
		return
	Log.debug("Map option named ", p_map.map_name, " added")
	label.text = "Map" + p_map.map_name
	sub_viewport.add_child(p_map)
	p_map.add_child(MapDisplayCamera.new())
