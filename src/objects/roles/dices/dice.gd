class_name Dice
extends Node2D

@onready var number_label: Label = %NumberLabel

@export var sides := 6
@export var duration := 0.5


#-----------------------------------------------------------------#
## Roll the dice and return the result.
## If play_animation is true, the animation will be played.
## The result will be already set and returned before the animation starts.
func roll(play_animation := true) -> int:
	if _anim_process.is_playing():
		Log.warning("The dice is still rolling, but roll is called again")
		return -1
	_result = randi_range(1, sides)
	if play_animation:
		anim_roll()
	return _result

#-----------------------------------------------------------------#
var _result: int


func get_result() -> int:
	return _result


func set_result(p_result: int) -> bool:
	if _anim_process.is_playing():
		Log.warning("The dice is rolling, but set_result is called on it")
		return false
	_result = p_result
	return true

#-----------------------------------------------------------------#
var _anim_process := Anim.AnimProcess.new()


func get_anim_process() -> Anim.AnimProcess:
	return _anim_process


## Play the animation of rolling the dice.
## This function has no effect on the final result! (The animation is a lie)
## The result is already determined before the animation starts.
## Use roll to get a random result, or call set_result to set a desired result
func anim_roll() -> void:
	_anim_process.start()
	var tweener := create_tween().tween_method(_anim_once, 0, 1, duration)
	await tweener.set_ease(Tween.EASE_OUT).finished
	_anim_process.end()


func _anim_once(progress: float) -> void:
	if progress != 1:
		number_label.text = str(randi_range(1, sides))
	else:
		number_label.text = str(_result)

#-----------------------------------------------------------------#
const DICE_SCENE = preload("uid://cq6g12x1ng2q3")


static func create():
	return DICE_SCENE.instantiate()
