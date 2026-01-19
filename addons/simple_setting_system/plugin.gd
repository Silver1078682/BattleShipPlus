@tool
extends EditorPlugin

const ICON_PATH = "asset/icons/"
const SRC_PATH = "src/"


func _enter_tree():
	add_custom_type("Component", "MarginContainer", preload(SRC_PATH + "core/component.gd"), preload(ICON_PATH + "Component.png"))
	add_custom_type("AdvancedComponent", "Component", preload(SRC_PATH + "core/advanced_component.gd"), preload(ICON_PATH + "Component.png"))
	add_custom_type("Setting", "Resource", preload(SRC_PATH + "core/setting.gd"), preload(ICON_PATH + "Component.png"))


func _exit_tree():
	remove_custom_type("Component")
	remove_custom_type("AdvancedComponent")
	remove_custom_type("Setting")
