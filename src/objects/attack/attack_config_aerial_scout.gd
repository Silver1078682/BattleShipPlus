class_name AttackConfigAerialScout
extends AttackConfig

func get_exposure_key(attack: Attack) -> String:
	var source_ship_id = attack.meta.get("source_ship_id", null)
	if source_ship_id == null:
		return "Exposure"
	return "AerialScoutFrom" + str(source_ship_id as int)
