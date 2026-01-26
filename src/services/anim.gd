class_name Anim
extends CenterContainer

#-----------------------------------------------------------------#
static var instance: Anim
static var pop_up_label: Label


func _init() -> void:
	assert(not instance, "a singleton already exists")
	instance = self


func _ready() -> void:
	pop_up_label = $Label
	Log.debug("Anim instance ready")


static func sleep(duration: float) -> void:
	if duration:
		await instance.get_tree().create_timer(duration).timeout

#-----------------------------------------------------------------#
signal anim_finished


static func wait_anim() -> void:
	if _global_anim_counter > 0:
		await instance.anim_finished


static var _global_anim_counter: int


static func add_anim_reference() -> void:
	_global_anim_counter += 1


static func delete_anim_reference() -> void:
	_global_anim_counter -= 1
	if _global_anim_counter <= 0:
		instance.anim_finished.emit()


#-----------------------------------------------------------------#
class AnimProcess:
	signal anim_finished

	var _anim_count = 0


	func wait():
		if _anim_count > 0:
			await anim_finished


	func start():
		if _anim_count == 0:
			Anim.add_anim_reference()
		_anim_count += 1


	func is_playing():
		return _anim_count > 0


	func end():
		_anim_count -= 1
		if _anim_count <= 0:
			Anim.delete_anim_reference()
			anim_finished.emit()


	func free() -> void:
		if _anim_count > 0:
			Anim.delete_anim_reference()
			Log.warning("anim aborted")


	func tween_property(node: Node, property: NodePath, final_val: Variant, duration: float) -> PropertyTweener:
		start()
		var tweener := node.create_tween().tween_property(node, property, final_val, duration)
		tweener.finished.connect(end)
		return tweener

#-----------------------------------------------------------------#
static var _pop_up_tween: Tween
static var pop_up_anim_process := AnimProcess.new()


static func pop_up(text: Variant) -> void:
	if _pop_up_tween:
		pop_up_anim_process.end()
		_pop_up_tween.kill()

	pop_up_anim_process.start()

	_pop_up_tween = instance.create_tween()

	pop_up_label.text = str(text)
	pop_up_label.modulate.a = 1
	await _pop_up_tween.tween_property(pop_up_label, "modulate:a", 0, 2).finished

	pop_up_anim_process.end()


#-----------------------------------------------------------------#
static func fade_out(object: CanvasItem, duration := 1.0) -> Tweener:
	return object.create_tween().tween_property(object, "modulate:a", 0, duration)
