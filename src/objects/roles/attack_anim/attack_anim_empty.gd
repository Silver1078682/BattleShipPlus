extends AttackAnim

@onready var anim_pos: Node2D = $Node2D


func _anim_display(coord := attack.center if attack else Vector2i.ZERO) -> void:
	position = Map.coord_to_pos(coord) + (Map.coord_to_pos(Vector2i(1, -2)) / 2.0)
	show()


func _anim_fly_to(_coord := attack.center if attack else Vector2i.ZERO) -> void:
	pass


func _anim_attack(coords: Array) -> void:
	if attack.config.use_dice:
		await dice.anim_roll()
	if attack.result != Attack.Result.SUCCESS:
		return
	for coord: Vector2i in coords:
		anim_pos.global_position = Map.coord_to_pos(coord)
		animation.play(&"Explosion")
