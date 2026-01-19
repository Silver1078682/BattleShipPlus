class_name SunkShipIndicator
extends Control

signal count_changed
var _count := 1
var count: int:
	get:
		return _count
	set(p_count):
		if _count != p_count:
			_count = p_count
			count_changed.emit()

@onready var texture_rect: TextureRect = %TextureRect
@onready var type: Label = %Type


func _ready() -> void:
	texture_rect.texture = Warship.get_texture(name)
	type.text = Warship.get_config(name).abbreviation
	renamed.connect(Log.error.bind("SunkShipIndicator renamed after ready"))
