class_name ActionAttack
extends ActionOperation
## [Action]s of attacking enemy ships
##
## To cutomize an [ActionAttack], Here is ur option. [br]
## 1. Set the attack_layer_marker to override the area to attack. [br]
## 2. Modify [member attack.meta] in virtual function [method _get_attack]
## to include extra infomation on the attack [br]
## 3. Override [method _get_attack_base_damage], [method _get_attack_center] and [method _get_attack_damages]
## to control attack parameter dynamically [br]
## 4. For even finer control, override [method._lauch_attack]

## If you wnat to modify the effect of an [Attack], see [AttackConfig] instead

@export_group("attack")
@export var attack_layer_marker: ScopeMarker:
	set(p_attack_layer_marker):
		if p_attack_layer_marker == null:
			Log.error("Trying to assign the attack_layer_marker of an ActionAttack with type nil")
			return
		p_attack_layer_marker.map_layer = Map.Layer.ATTACK_LAYER
		attack_layer_marker = p_attack_layer_marker

## The [AttackConfig] of the [ActionAttack]
@export var attack_config: AttackConfig = preload("uid://d0dpusquoqm0b")
## The base damage, ignored when [method _get_attack_base_damage] is overridden
@export var damage: int
## If set true, the center of [member attack_area] will follow player's mouse.
@export var attack_follow_mouse: bool

@export_group("deperecated")
## The [Area] as the shape of the [Attack].
@export var attack_area: Area


#-----------------------------------------------------------------#
func _committed() -> bool:
	if not Game.instance.cursor.is_valid(true):
		return false

	#unmark_attack_map_layer()
	return launch_attack()


func _cancelled() -> void:
	super()
	#unmark_attack_map_layer()


func _update_cursor(p_coord: Vector2i, cursor: Cursor) -> void:
	super(p_coord, cursor)
	#mark_attack_map_layer()


func _exited() -> void:
	super()
	#unmark_attack_map_layer()


#-----------------------------------------------------------------#
# override this function so that attack_layer_marker will also be updated when neccessary
func _get_scope_markers_list() -> Array[ScopeMarker]:
	var result: Array[ScopeMarker]
	result.assign([action_layer_marker, attack_layer_marker])
	return result

#-----------------------------------------------------------------#


func launch_attack() -> bool:
	if not attack_config:
		Log.warning("The attack config not assigned to %s" % self)
		return false

	_launch_attack()
	return true


func _launch_attack() -> Attack:
	var attack := _get_attack()
	var coords := _get_attack_damages()
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
## Returns the [Attack] object of the [ActionAttack]
func _get_attack() -> Attack:
	var attack := Attack.create_from_config(attack_config)
	attack.center = _get_attack_center()
	attack.base_damage = _get_attack_base_damage()
	return attack


## Returns the default base damage of the ActionAttack.
## See [Attack.base_damage]
func _get_attack_base_damage() -> int:
	return damage


## Returns the center of the Attack.
## See [Attack.center]
func _get_attack_center() -> Vector2i:
	return Cursor.coord if attack_follow_mouse else _ship.coord


## Returns all coordinates will be attacked in a dictionary
func _get_attack_damages() -> Dictionary[Vector2i, int]:
	if not attack_layer_marker:
		Log.warning("The attack_layer_marker is not assigned for %s" % self)
		return { }
	return attack_layer_marker.get_coords()


#-----------------------------------------------------------------#
func _get_cursor_check_list(p_coord: Vector2i) -> Dictionary[String, bool]:
	var list := super(p_coord)
	list["CANNOT_ATTACK_HERE"] = list.get("CANNOT_MOVE_HERE", false)
	list.erase("CANNOT_MOVE_HERE")
	return list


#-----------------------------------------------------------------#
func _to_string() -> String:
	return super() % ("ATK_AREA:" + str(attack_area))
