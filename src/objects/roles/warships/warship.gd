class_name Warship
extends Node2D
## Warship
##

#-----------------------------------------------------------------#
# node pointers
@onready var label: Label = $Label
@onready var animation: AnimationPlayer = $Animation
@onready var action_button: ActionButton = $ActionButton

## Config of the warship
## A config can only (and must) be applied before the node is ready
@export var config: WarshipConfig: # dependency injection
	set(p_config):
		assert(not config, "config applied")
		assert(not is_node_ready())
		health = p_config.health
		torpedo = p_config.torpedo
		config = p_config

## Coordinate of the ship
var coord: Vector2i:
	set(p_coord):
		position = Map.coord_to_pos(p_coord)
		coord = p_coord

var id: int

var anim_process := Anim.AnimProcess.new()


#-----------------------------------------------------------------#
func _ready() -> void:
	assert(config)


## Usually invoked by [method Fleet.get_hit_ships]
## Handle an attack, return false if the warship is immune to it.
func handle_attack(damage: int, attack: Attack) -> bool:
	Log.debug(self, " handling ", attack, " damage = ", damage)
	if config.is_immune_to(attack):
		Log.debug("%s is immune from the attack" % self)
		return false

	health -= damage
	if health <= 0:
		if not is_exposed():
			apply_exposure(attack)
			is_highlighted = true
			return true
	is_highlighted = is_highlighted or attack.scouting
	apply_exposure(attack)
	return true


#-----------------------------------------------------------------#
## called every time game phase changed
func update() -> void:
	# mine ----------------------
	if _last_mine_coord != coord:
		is_in_mine_zone = handle_mine_attack()
		if is_in_mine_zone:
			_last_mine_coord = coord

	# action --------------------
	action_terminator = null
	_actions = config.get_actions(Phase.manager.get_phase().name)
	_update_actions()

	# push state ----------------
	if not as_enemy and is_exposed() and health > 0:
		# this update the mirror warship
		call_mirror("deserialized", serialized())

#-----------------------------------------------------------------#
# Actions in this phase
var _actions: Array[Action]
var action_terminator: Action


func add_action(action: Action) -> void:
	_actions.append(action)
	_update_actions()


func remove_action(action: Action) -> void:
	_actions.erase(action)
	_update_actions()


func clear_action() -> void:
	_actions.clear()
	_update_actions()


func has_any_action() -> bool:
	return not _actions.is_empty()


func get_actions() -> Array[Action]:
	return _actions


func _update_actions() -> void:
	action_button.reset()
	action_button.is_activated = has_any_action()
	for action in _actions:
		if not action:
			Log.error("trying to assign an nil as action to ship type %s" % config.name)
			continue
		if action is ActionOperation:
			action.ship = self

#-----------------------------------------------------------------#
## leave stage (on death or anything else)
signal stage_left

var _is_leaving_stage: bool


func is_leaving_stage() -> bool:
	return _is_leaving_stage


func leave_stage(with_explosion: bool = false) -> void:
	if _is_leaving_stage:
		Log.warning("%s is already leaving the stage, skipping" % self)
		return
	_is_leaving_stage = true

	if with_explosion:
		animation.play("Explosion")
		await animation.animation_finished
	await anim_process.wait()

	var fleet: Fleet = get_parent()
	assert(fleet, "an Orphan ship leaving the stage")
	assert(fleet.get_ship_at(coord) == self, "ship leaving the stage but not registered at its position")

	fleet.unregister_ship(self)
	if is_exposed() and not as_enemy:
		call_mirror(&"leave_stage", with_explosion)

	stage_left.emit()
	queue_free()
	Log.info("%s left the stage" % self)


## Call a function on the mirror of this ship, if it exists (for ships that are exposed to the opponent)
func call_mirror(function_name: StringName, ...args) -> void:
	const MAX_TRY = 5
	if not is_exposed():
		Log.error("Trying to call_mirror on an unexposed warship, which does not has a mirror")
		return
	if as_enemy:
		Log.error("Trying to call_mirror on a warship which itself is a mirror")

	for i in MAX_TRY:
		if has_mirror:
			var node_path: = NodePath("Opponent/Fleet/Warship" + str(id))
			Network.instance.rpc_callv(node_path, function_name, args)
			return
		await Anim.sleep(2 ** i / 2.0)
		if i == MAX_TRY - 1:
			Log.error("call_mirror ", function_name, " on ", self, "failed after 5 tries")

#-----------------------------------------------------------------#
## Health
signal health_changed(p_health: int)
var _health: int
var health: int:
	get:
		return _health
	set(p_health):
		if _health != p_health:
			health_changed.emit(p_health)
			_health = p_health
			if p_health <= 0:
				death.emit()
				_on_death()

signal death


func _on_death() -> void:
	assert(self.is_node_ready()) ## In case a ship dies immediately on spawn
	Log.info("%s is destroyed" % self)
	leave_stage(true)
	Player.instance.handle_death(id, config.name)
	Network.instance.rpc_call(^"Opponent", &"handle_death", id, config.name)

#-----------------------------------------------------------------#
## Torpedo
signal torpedo_changed(p_torpedo: int)
var _torpedo: int
var torpedo: int:
	get:
		return _torpedo
	set(p_torpedo):
		if _torpedo != p_torpedo:
			torpedo_changed.emit(p_torpedo)
			_torpedo = p_torpedo

#-----------------------------------------------------------------#
## If the warship is already in a mine zone
var is_in_mine_zone := false

## Coordinate of last mine zone the ship has been,
## Set null if the warship has never entered any mine zone
var _last_mine_coord: Variant:
	set(p_last_mine_coord):
		assert(p_last_mine_coord == null or p_last_mine_coord is Vector2i)
		_last_mine_coord = p_last_mine_coord


func handle_mine_attack() -> bool:
	if _is_leaving_stage:
		return false
	if Opponent.mine.has_mine_at(self.coord):
		Log.debug("%s encounter a mine" % self)
		if config.can_remove_mine:
			Log.debug("%s removes the mine" % self)
			Network.instance.rpc_call(^"Player/Mine", &"remove_mine_at", coord)

		var attack := Attack.create_from_name("Mine")
		attack.scouting = false
		return handle_attack(Mine.DAMAGE, attack)
	return false

#-----------------------------------------------------------------#
signal exposed
signal concealed
var exposure_reasons: Dictionary[StringName, Variant]


func apply_exposure(attack: Attack) -> void:
	if not attack.scouting:
		return
	if exposure_reasons.is_empty():
		Log.debug("%s is exposed" % self)
		exposed.emit()
	exposure_reasons[attack.get_exposure_key()] = null


func revert_exposure(key: StringName) -> void:
	exposure_reasons.erase(key)
	if exposure_reasons.is_empty():
		concealed.emit()


func is_exposed() -> bool:
	return not exposure_reasons.is_empty()

# #-----------------------------------------------------------------#
# ## is the warship exposed (Discovered by opponent).
# var is_exposed := false:
# 	set(p_is_exposed):
# 		if not is_exposed and p_is_exposed:
# 			Log.debug("%s is exposed" % self)
# 			exposed.emit()
# 		is_exposed = p_is_exposed

## If we can be assertive that a mirror peer instance is created
var has_mirror := false

## is the warship an enemy mirror.
var as_enemy := false:
	get:
		var fleet := get_parent()
		if not fleet or fleet is not Fleet:
			return false
		return fleet.is_enemy_mirror

#-----------------------------------------------------------------#
signal highlighted
signal unhighlighted
## If the ship is highlight mode, a ship will be highlighted for a round after exposure.
## A highlighted ship will display its type label and health by default
var is_highlighted := false:
	set(p_is_highlighted):
		if p_is_highlighted and not is_highlighted:
			highlighted.emit()
		if is_highlighted and not p_is_highlighted:
			unhighlighted.emit()
		is_highlighted = p_is_highlighted

#-----------------------------------------------------------------#
const WARSHIP_SCENE = preload("uid://0104oo2lacg")

const CONFIG_PATH = "res://scr/objects/roles/warships/resources/%s.tres"


## Returns a new instance of Warship with the provided WarshipConfig.
## Always create a ship with Warship.create_from_* function to avoid Null Reference Exception.
## In other word, never do Warship.new() or var ship = preload(WARSHIP_SCENE).new()
static func create_from_config(warship_config: WarshipConfig) -> Warship:
	if not warship_config:
		Log.error("creating Warship from config null")
		return null

	var warship: Warship = WARSHIP_SCENE.instantiate()
	warship.config = warship_config
	return warship


## Returns a new instance of Warship with the provided name.
## See [create_from_config]
static func create_from_name(warship_name: String) -> Warship:
	var warship_config := ResourceUtil.load_resource("warships", warship_name) as WarshipConfig
	if not warship_config:
		return null

	return create_from_config(warship_config)


static func get_config(warship_name: String) -> WarshipConfig:
	return ResourceUtil.load_resource("warships", warship_name) as WarshipConfig


#-----------------------------------------------------------------#
func serialized() -> Dictionary[StringName, Variant]:
	return Serializer.serialize_by_properties(
		self,
		[&"health", &"torpedo", &"coord"],
		{ &"config": config.name, &"id": id },
	)


# a deserialized ship update its id according to the given list
func deserialized(prop_list: Dictionary[StringName, Variant]) -> void:
	# manually update id & name
	id = prop_list.id
	name = "Warship" + str((prop_list.id as int))
	# set _health to avoid triggering setter
	_health = prop_list.health
	# use move_ship_to on necessary
	if coord != prop_list.coord:
		if self.is_node_ready():
			if not (get_parent() as Fleet).move_ship_to(self, prop_list.coord):
				Log.error("Calling move_ship_to on ", self, "failed")
		coord = prop_list.coord
	torpedo = prop_list.torpedo

#-----------------------------------------------------------------#
const TEXTURE_PATH = "res://asset/texture/roles/warships/%s"


static func get_texture(warship_type: String) -> Texture:
	var dir_access := FileUtil.open_dir(TEXTURE_PATH % warship_type)
	var file_names := Array(dir_access.get_files())
	var file_name: String = file_names.pick_random().trim_suffix(".import")
	return load(TEXTURE_PATH % warship_type + "/" + file_name)


const DESTROYER = "Destroyer"
const LIGHT_CRUISER = "LightCruiser"
const HEAVY_CRUISER = "HeavyCruiser"
const BATTLESHIP = "Battleship"
const CARRIER = "Carrier"
const SUBMARINE = "Submarine"
const CARGO_SHIP = "CargoShip"
const MINE_LAYER = "MineLayer"

const NAMES: PackedStringArray = [
	DESTROYER,
	LIGHT_CRUISER,
	HEAVY_CRUISER,
	BATTLESHIP,
	CARRIER,
	SUBMARINE,
	CARGO_SHIP,
	MINE_LAYER,
]


#-----------------------------------------------------------------#
# <as_enemy?abbr [health / max_health] @(coord) id>
func _to_string() -> String:
	var ship_name = config.abbreviation
	return "<%s%s%s HP[%d / %d] TOR[%d/%d] @%s %d>" % [
		"!" if as_enemy else "-",
		_get_expose_indicator_char(),
		ship_name,
		health,
		config.health,
		torpedo,
		config.torpedo,
		coord,
		id,
	]


func _get_expose_indicator_char() -> String:
	if is_exposed() and has_mirror:
		return "*"
	if is_exposed() and not has_mirror:
		return "?"
	return "-"
