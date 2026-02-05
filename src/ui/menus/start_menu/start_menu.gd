extends Control

@onready var ip_edit: LineEdit = %IPEdit
@onready var main: Control = %Main
@onready var setting_menu: Control = $Setting/SettingMenu
@onready var map_selector: MarginContainer = %MapSelector
@onready var waiting_screen: WaitingScreen = %WaitingScreen

var display: Node:
	set(p_display):
		if display:
			display.hide()
		if p_display:
			p_display.show()
		display = p_display


#-----------------------------------------------------------------#
func _ready() -> void:
	display = main


func _on_host_button_pressed() -> void:
	display = map_selector


func _on_map_selected() -> void:
	if Network.instance.start_server() == OK:
		waiting_screen.setup(tr("HOST_CREATE_ROOM%s") % Network.get_local_ip())
		display = waiting_screen


func _on_join_button_pressed() -> void:
	Network.instance.start_client(ip_edit.text)
	waiting_screen.setup(tr("CONNECTING_TO_ROOM%s") % ip_edit.text)
	display = waiting_screen


func _on_setting_button_pressed() -> void:
	display = setting_menu
