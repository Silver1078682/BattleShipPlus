class_name NodeUtil

## await is required before ensure_ready function
static func ensure_ready(node: Node) -> void:
	if not node.is_node_ready():
		await node.ready


static func set_parent_of(node: Node, parent: Node) -> void:
	if node.get_parent():
		node.reparent(parent)
	else:
		parent.add_child(node)


static func find_first_ancestor_matching_condition(node: Node, condition: Callable) -> Node:
	var ancestor: = node.get_parent()
	while ancestor != null and not condition.call(ancestor):
		ancestor = ancestor.get_parent()
	return ancestor
