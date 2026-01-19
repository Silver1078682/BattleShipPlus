class_name Serializer
extends Node

#-----------------------------------------------------------------#
static func serialize(variant: Variant) -> Variant:
	if variant is Array:
		return serialize_an_array(variant.duplicate())
	if variant is Dictionary:
		return serialize_a_dictionary(variant)

	if variant is Object:
		if not variant.has_method("serialized"):
			Log.error("The object should has a function named serialized to be passed in rpc")
			return null
		return variant.serialized()

	return variant


#-----------------------------------------------------------------#
static func serialize_an_array(array: Array) -> Array:
	var result := array.duplicate()
	for i in array.size():
		result[i] = serialize(array[i])
	return result


static func serialize_a_dictionary(dictionary: Dictionary) -> Dictionary:
	var result: Dictionary
	for key in dictionary.keys():
		result.set(serialize(key), serialize(dictionary[key]))
	return result


#-----------------------------------------------------------------#
static func serialize_by_properties(
		object: Object,
		prop_list: Array,
		prop_dict: Dictionary[StringName, Variant] = { },
		ignore_empty_string := true,
) -> Dictionary[StringName, Variant]:
	var result: Dictionary[StringName, Variant] = { }
	for prop_name in prop_list:
		var value = object.get(prop_name)
		if ignore_empty_string and value is String and value.is_empty():
			continue
		result[prop_name] = value
	result.merge(prop_dict, true)
	return result


static func deserialize_by_properties(
		object: Object,
		prop_list: Dictionary[StringName, Variant],
		exclusion_list: Array[StringName] = [],
		default_list: Dictionary[String, Variant] = { },
) -> void:
	for prop_name in exclusion_list:
		prop_list.erase(prop_name)
	var actual_list = prop_list.merged(default_list)
	for prop_name in actual_list:
		object.set(prop_name, prop_list[prop_name])


static func serialize_recursive() -> void:
	pass
