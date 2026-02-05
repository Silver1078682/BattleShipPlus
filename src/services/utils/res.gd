class_name ResourceUtil
## Alternative to ResourceLoader

const RESOURCE_FOLDER = "res://asset/resources/"

## Load a resource
## load_resource("type", "name") is a snippet to load("res://asset/resources/type/name.tres")
## extra restrictions: [param type] should be snake_case. [param name] should be PascalCase.
## return [param fallback] on failure, or null [param fallback] when not set
## by default load a .tres, but you can also override the [param file_ext]
static func load_resource(type: String, resource_name: String, fallback: Resource = null, file_ext := "tres") -> Resource:
	if resource_name.to_pascal_case() != resource_name:
		Log.error("Resource name should be PascalCase, but given: %s" % resource_name)
		return null
	var path := RESOURCE_FOLDER + "%s/%s.%s" % [type, resource_name, file_ext]
	if not ResourceLoader.exists(path):
		if fallback == null:
			Log.error("file does not exist at: %s" % path)
		return fallback

	return load(path)


static func list_directory(type: String) -> PackedStringArray:
	var path := RESOURCE_FOLDER + type
	if not DirAccess.dir_exists_absolute(RESOURCE_FOLDER):
		Log.error("folder does not exist at: %s" % path)
		return []
	var result := []
	for i in ResourceLoader.list_directory(path):
		if i.ends_with("/"):# filter the subdirectory
			continue
		if i.begins_with("_"):# filter file starting with "_
			continue
		result.append(i)
	return result


static func load_directory(type: String) -> Array[Resource]:
	var resources: Array[Resource]
	for resource_name in list_directory(type):
		var path := RESOURCE_FOLDER + "%s/%s" % [type, resource_name]
		resources.append(load(path))
	return resources
