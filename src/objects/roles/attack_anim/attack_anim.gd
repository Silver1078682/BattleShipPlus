class_name AttackAnim
extends Node2D
## Animation of an attack with some pre-made behavior

@onready var sprite: Sprite2D = $Sprite
@onready var animation: AnimationPlayer = $Animation
var dice: Dice = null

#-----------------------------------------------------------------#
## the [Attack] this [AttackAnim] represents.
## Should (and must need to) be set before ready
@export var attack: Attack:
	set(p_attack):
		attack = p_attack
		assert(not is_node_ready())


func _ready() -> void:
	assert(attack)
	assert(attack.config)
	if attack:
		sprite.texture = attack.config.texture
		if attack.config.use_dice:
			dice = Dice.create()
			dice.set_result(attack.dice_result)
			add_child(dice)

#-----------------------------------------------------------------#
var anim_process := Anim.AnimProcess.new()

signal request_attack


## Play the animation, coords is where the
## A signal is emitted when the pre-attack animation is finished and an attack is required
func play(coords: Array) -> void:
	_anim_display()
	await _anim_fly_to()
	await _anim_attack(coords)
	request_attack.emit()
	if not attack.has_finished():
		await attack.finished
	if should_explode():
		await _anim_explode()
	else:
		await _anim_fade_out()


func _anim_display(coord := attack.center if attack else Vector2i.ZERO) -> void:
	position = Map.coord_to_pos(coord - Vector2i.ONE)
	show()


func _anim_fly_to(coord := attack.center if attack else Vector2i.ZERO) -> void:
	var tweener := anim_process.tween_property(self, "position", Map.coord_to_pos(coord), attack.config.flight_time)
	tweener.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await tweener.finished


func _anim_fade_out() -> void:
	anim_process.start()
	await Anim.fade_out(self).finished
	anim_process.end()
	queue_free()


func _anim_attack(coords: Array) -> void:
	anim_process.start()
	if attack.config.use_dice:
		await dice.anim_roll()
	for coord: Vector2i in coords:
		pass
	anim_process.end()


func should_explode() -> bool:
	return attack.config.should_explode and attack.result == attack.config.explode_when


func _anim_explode() -> void:
	anim_process.start()
	animation.play("Explosion")
	await animation.animation_finished
	anim_process.end()
	queue_free()

#-----------------------------------------------------------------#
const ATTACK_ANIM_SCENE = preload("uid://b1yerg1ur6ei8")
