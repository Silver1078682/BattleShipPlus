class_name ResourceUtil

static func load_resource(type: String, resource_name: String, fallback: Resource = null) -> Resource:
	if resource_name.to_pascal_case() != resource_name:
		Log.error("Resource name should be PascalCase, but given: %s" % resource_name)
		return null
	var path := "res://asset/resources/%s/%s.tres" % [type, resource_name]
	if not ResourceLoader.exists(path):
		if fallback == null:
			Log.error("file does not exist at: %s" % path)
		return fallback

	return load(path)
