class_name AttackConfigDiveAircraft
extends AttackConfigAerial

# For a DiveAircraft the base_damage is 1 by default
func _get_success_damage(_base_damage: int, attack: Attack, defense_level: int) -> int:
	return attack.dice_result - defense_level
