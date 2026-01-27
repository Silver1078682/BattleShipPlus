class_name AttackConfigAerialScout
extends AttackConfig

const AERIAL_SCOUTER = ["Carrier", "Battleship"]
const EXPOSURE_KEY = "AerialScoutFrom"


func get_exposure_key(attack: Attack) -> String:
	var source_ship_id = attack.meta.get("source_ship_id", null)
	if source_ship_id == null:
		return "Exposure"
	return EXPOSURE_KEY + str(source_ship_id as int)
