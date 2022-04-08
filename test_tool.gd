@tool

extends EditorScript


var resource: Resource = preload("res://resources/new_resource.tres")
var graph_node_prop_container_tscn := preload("res://addons/resources_map/graph_node_prop_container.tscn")


func _run():
	var props = _get_exported_props()
	
	var graph_edit = get_scene().get_node("GraphEdit")
	for child in graph_edit.get_children():
		graph_edit.remove_child(child)
	
	var graph_node = _create_graph_node(props)
	graph_edit.add_child(graph_node)
	graph_node.owner = get_scene()


func _create_graph_node(props: Array) -> GraphNode:
	var graph_node := GraphNode.new()
	
	for prop in props:
		var prop_container = graph_node_prop_container_tscn.instantiate()
		prop_container.setup(prop)
		graph_node.add_child(prop_container)
	
	return graph_node


func _get_exported_props() -> Array:
	const PROPERTY_USAGE_EXPORT: int = 8199
	var resource_script = resource.script as Script
	var props = resource_script.get_script_property_list()
	
#	print(props)
#	print("--------------------")
	var filtered_props = props.filter(func(x): return x.usage == PROPERTY_USAGE_EXPORT)
#	print(filtered_props)
	
	return filtered_props
