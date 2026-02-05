extends ProgressBar

@onready var particles: CPUParticles2D = $Particles
var _ship:
	get:
		return get_parent()


func _ready() -> void:
	if _ship.as_enemy:
		hide()
	max_value = _ship.config.health


func set_health(p_health: int) -> void:
	if not is_node_ready():
		await ready

	if p_health < value:
		if _ship.animation and not _ship.animation.is_playing():
			_ship.animation.play("Damage")

	value = p_health
	if p_health > 0 and p_health <= max_value / 3:
		particles.show()
		particles.emitting = true
	else:
		particles.hide()
		particles.emitting = true
