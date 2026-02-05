class_name ActionAttack
extends ActionOperation
## [Action]s of attacking enemy ships

@export_group("attack")
## The [Area] as the shape of the [Attack].
@export var attack_area: Area
## If set true, the center of [member attack_area] will follow player's mouse.
@export var attack_follow_mouse: bool
## The [AttackConfig] of the [ActionAttack]
@export var attack_config: AttackConfig = preload("uid://d0dpusquoqm0b")
## The base damage of the [ActionAttack], note that actual damage may varies depending on the [param AttackConfig].
@export var damage: int


#-----------------------------------------------------------------#
func _committed() -> bool:
	if not Game.instance.cursor.is_valid(true):
		return false

	var coord := Cursor.coord if attack_follow_mouse else _ship.coord
	unmark_attack_scope()
	return attack_at(coord)


func _input(event: InputEvent) -> bool:
	if attack_area:
		if event.is_action_pressed("rotate_forward"):
			attack_area.rotate(1)
			mark_attack_scope()
		if event.is_action_pressed("rotate_backward"):
			attack_area.rotate(-1)
			mark_attack_scope()
	return false


func _cancelled() -> void:
	super()
	unmark_attack_scope()


func _update_cursor(p_coord: Vector2i, cursor: Cursor) -> void:
	super(p_coord, cursor)
	mark_attack_scope()


func _exited() -> void:
	super()
	unmark_attack_scope()


#-----------------------------------------------------------------#
func attack_at(coord: Vector2i) -> bool:
	if not attack_config:
		Log.warning("The attack config not assigned to %s" % self)
		return false

	_attack_at(coord)
	return true


func _attack_at(coord: Vector2i) -> Attack:
	var attack := _get_attack(coord)
	var coords := _get_attack_damages(coord)
	_play_attack_anim(coords, attack)
	attack.launch(coords)
	return attack


# play action locally
func _play_attack_anim(coords: Dictionary[Vector2i, int], attack: Attack) -> AttackAnim:
	var attack_anim := attack.create_attack_anim()
	if attack_anim:
		Game.instance.add_child(attack_anim)
		attack_anim.play(coords.keys())
	return attack_anim


#-----------------------------------------------------------------#
func _get_attack(coord: Vector2i) -> Attack:
	var attack := Attack.create_from_config(attack_config)
	attack.center = coord
	attack.base_damage = _get_attack_damage()
	return attack


## Returns the default damage of the ActionAttack
func _get_attack_damage() -> int:
	return damage


## Returns all coordinates will be attacked
func _get_attack_damages(offset: Vector2i) -> Dictionary[Vector2i, int]:
	attack_area.offset = offset
	if not attack_area:
		Log.warning("The attack area is not assigned %s" % self)
		return { }
	return attack_area.get_coords()


#-----------------------------------------------------------------#
func mark_attack_scope() -> void:
	if _action_in_process != self:
		return
	if not attack_area:
		Log.warning("The area of attack action is not assigned to %s" % self)
		return

	var coord := Game.instance.cursor.coord if attack_follow_mouse else _ship.coord
	Map.instance.attack_scope.set_dict(_get_attack_damages(coord))


func unmark_attack_scope() -> void:
	Map.instance.attack_scope.clear()


#-----------------------------------------------------------------#
func _get_cursor_check_list(p_coord: Vector2i) -> Dictionary[String, bool]:
	var list := super(p_coord)
	list["CANNOT_ATTACK_HERE"] = list.get("CANNOT_MOVE_HERE", false)
	list.erase("CANNOT_MOVE_HERE")
	return list


#-----------------------------------------------------------------#
func _to_string() -> String:
	return super() % ("ATK_AREA:" + str(attack_area))
