extends AttackAnim

func _ready() -> void:
	super()
	if not attack.check_meta("attacker_type"):
		return
	var attacker_type: String = attack.meta["attacker_type"]
	sprite.texture = Warship.get_texture(attacker_type)
	$Label.text = Warship.get_config(attacker_type).abbreviation
