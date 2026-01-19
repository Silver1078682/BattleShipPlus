extends Control

@onready var ip_edit: LineEdit = %IPEdit
@onready var waiting_screen: WaitingScreen = %WaitingScreen


#-----------------------------------------------------------------#
func _on_host_button_pressed() -> void:
	if Network.instance.start_server() == OK:
		waiting_screen.display(tr("HOST_CREATE_ROOM%s") % Network.get_local_ip())


func _on_join_button_pressed() -> void:
	Network.instance.start_client(ip_edit.text)
	waiting_screen.display(tr("CONNECTING_TO_ROOM%s") % ip_edit.text)
