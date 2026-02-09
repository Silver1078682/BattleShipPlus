class_name WarshipConfig
extends Resource

## Warship config
@export_group("meta")
@export var name: String
@export var abbreviation: String
@export var description: String

@export_group("property")
@export var health: int
@export var motility: int
@export var aerial_defense: int
@export var torpedo: int
@export var artillery_distance: int
@export var artillery_level: int

@export var immune_attacks: Array[StringName] = [&"DestroyerScout"]


func is_immune_to(attack: Attack) -> bool:
	return attack.config.name in immune_attacks


@export var can_remove_mine := false

@export_group("arrange")
@export var cost: int
@export var arrange_limit: int = -1
@export var arrange_area: ArrangeArea
enum ArrangeArea {
	HOME,
	PUBLIC,
}

@export_group("action", "action_")
@export var action_groups: Dictionary[String, PhaseActionGroup]


func get_action_group(phase_name: String) -> PhaseActionGroup:
	return (action_groups.get(phase_name) as PhaseActionGroup)


func _to_string() -> String:
	return "HP:%d MOT:%d AERIAL:%d TOR:%d [%d]" % [health, motility, aerial_defense, torpedo, cost]
