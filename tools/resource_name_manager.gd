@tool
class_name ResourceNameManager
extends EditorScript

func edit_a_directory(dir_access: DirAccess, property_name: String) -> void:
	for file_name in dir_access.get_files():
		if not file_name.ends_with(".tres"):
			continue
		var resource_path := dir_access.get_current_dir().path_join(file_name)
		var resource := ResourceLoader.load(resource_path)
		var resource_name := file_name.trim_suffix(".tres")
		resource.resource_name = resource_name
		if property_name:
			resource.set(property_name, resource_name)
		ResourceSettingSaver.save(resource, resource_path)


func go_through_resource_folder(dir_path: String, property_name_map: Dictionary[String, String]) -> void:
	var access := FileUtil.open_dir(dir_path)
	for dir_name in access.get_directories():
		var property_name: String = property_name_map.get(dir_name, "name")
		access.change_dir(dir_name)
		edit_a_directory(access, property_name)
		access.change_dir("..")


func _run() -> void:
	go_through_resource_folder(
		"res://asset/resources/",
		{ "actions": "action_name" },
	)
	print("Done!")
