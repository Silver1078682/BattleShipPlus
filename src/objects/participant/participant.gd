class_name Participant
extends Node2D

func _ready() -> void:
	set("fleet", $Fleet)
	set("mine", $Mine)
	Log.debug(name, "instance ready")


func setup() -> void:
	Log.info(name, " instance setup")
	_setup()


func _setup() -> void:
	get("fleet").setup()
	set("sunk", UI.instance.sunk.get_node(String(name)))
	Phase.manager.phase_changed.connect(get("mine").push_mines.unbind(1))
