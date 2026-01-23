extends Tester

@export var spawn_count: int


func _run():
	var arr := Map.instance.get_scope_public().keys()
	arr.shuffle()
	arr = arr.slice(0, spawn_count)
	for i: Vector2i in arr:
		_add_warship(i, "Submarine")
