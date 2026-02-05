extends Node

@onready var option_container: HBoxContainer = %OptionContainer
const MAP_SELECTOR_OPTION = preload("uid://djk3jbfsowy04")

signal map_selected


func _ready() -> void:
	Log.debug("Loading Map option")
	for map_scene in ResourceUtil.load_directory("maps"):
		var map_selector_option: MapSelectorOption = MAP_SELECTOR_OPTION.instantiate()
		map_selector_option.map_scene = map_scene
		option_container.add_child(map_selector_option)
		map_selector_option.selected.connect(map_selected.emit)
