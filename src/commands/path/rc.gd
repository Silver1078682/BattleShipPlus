extends Node

var server_commands := """
area base "warship all $ (1 1)"
area rect "a=(40,15) size=(2,2)--warship add $ Des"
area rect "a=(40,10) size=(2,2)--warship add $ Batt"
phase goto AerialScout
"""

var client_commands := """
area base "warship all $ (-1 -1)"
"""


func _enter_tree() -> void:
	var commands: String

	if Network.is_server():
		commands = server_commands
	elif Network.is_client():
		commands = client_commands
	await Anim.sleep(0.2)

	for command in commands.split("\n"):
		LimboConsole.execute_command(command)
