extends Label

func update_text() -> void:
	text = "Player {id}({Network})    ".format({ "id": Player.id, "Network": Network.instance })
