@tool
class_name PropertySetter
extends Node

@export var from: Node
@export var property_from: String
@export var property: String

@export_group("proxy", "proxy_expression_")
@export var proxy_expression_arg_name := "x"
@export var proxy_expression_base_instance: Node
@export var proxy_expression: String = "x":
	set(p_proxy_expression):
		_expression.parse(p_proxy_expression, ["x"])
		proxy_expression = p_proxy_expression

var _expression := Expression.new()
@export_group("tool")
@export_tool_button("as code") var as_code_button := func(): print(_as_code())


#-----------------------------------------------------------------#
func sync() -> void:
	_sync()


func _sync() -> void:
	if not from:
		push_error("PropertySetter from not set")
		return
	if not get_parent():
		push_error("PropertySetter does not have a parent")

	var value = from.get_indexed(property_from)
	get_parent().set_indexed(property, proxy(value))


func proxy(value) -> Variant:
	return _expression.execute([value], proxy_expression_base_instance)


#-----------------------------------------------------------------#
func _path_to_code(path: String) -> String:
	return path.replace_char(ord(":"), ord("."))


func _expression_to_code(expression: String, arg_name: String, value_string: String, all := false) -> String:
	var regex = RegEx.create_from_string(r"(?<![a-zA-Z\"'])\Q" + arg_name + r"\E(?![a-zA-Z1-3])")
	return regex.sub(expression, value_string, all)


const _SHORT_FORMAT := "{prop}={expression}"
const _MULTILINE_FORMAT := "var {arg_name} := {arg_value}\n{prop}={expression}"


func _as_code() -> String:
	var arg_value = "get_node(%s).%s" % [
		from.get_path_to(get_parent()),
		_path_to_code(property_from),
	]
	var use_multiline := false
	var expression := _expression_to_code(proxy_expression, proxy_expression_arg_name, arg_value)
	if expression.length() >= 80:
		use_multiline = true
	else:
		var expression2 := _expression_to_code(expression, proxy_expression_arg_name, arg_value)
		if expression != expression2:
			use_multiline = true
	if use_multiline:
		expression = proxy_expression
	else:
		expression = _expression_to_code(expression, proxy_expression_arg_name, arg_value, true)
	var result := (_MULTILINE_FORMAT if use_multiline else _SHORT_FORMAT).format(
		{
			"arg_name": proxy_expression_arg_name,
			"arg_value": arg_value,
			"prop": property,
			"expression": expression,
		},
	)
	return result


#-----------------------------------------------------------------#
func _init() -> void:
	_expression.parse("x", ["x"])
