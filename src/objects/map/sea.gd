class_name Sea
extends Scope

func _ready() -> void:
	set_dict(Map.instance.get_coords())
