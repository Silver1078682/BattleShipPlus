class_name Camera
extends Camera2D
## TODO optimize the camera movement

func _ready() -> void:
	Log.debug("Camera instance ready")


func move_to_position(pos: Vector2, slide := true) -> void:
	if not slide:
		position_smoothing_enabled = false
	position = pos
	if not slide:
		set_deferred("position_smoothing_enabled", true)


const SPEED = 0.01


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		if event is InputEventMouseMotion:
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
				position -= event.screen_velocity * SPEED


const KEY_SPEED = 100


func _unhandled_input(event) -> void:
	if event.is_action_pressed("zoom_out"):
		zoom /= 1.1
	if event.is_action_pressed("zoom_in"):
		zoom *= 1.1

	if event.is_action("right", true):
		position.x += KEY_SPEED
	if event.is_action("left", true):
		position.x -= KEY_SPEED
	if event.is_action("up", true):
		position.y -= KEY_SPEED
	if event.is_action("down", true):
		position.y += KEY_SPEED
