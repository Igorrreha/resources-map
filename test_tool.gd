@tool

extends EditorScript


var _graph_node_prop_container_tscn := preload("res://addons/resources_map/graph_node_prop_container.tscn")
var _graph_node_tscn := preload("res://addons/resources_map/graph_node.tscn")
var _graph_edit: GraphEdit
var _resources_connections: Dictionary # {Resource, Array[ResourceConnection]}


func _run():
	var resources: Array[Resource] = _get_all_resources()
	
	_fill_resources_connections(resources)
	
	_graph_edit = get_scene().get_node("GraphEdit")
	_clear_graph_edit()
	
	for resource in _resources_connections:
		var graph_node = _create_graph_node(resource)
		_graph_edit.add_child(graph_node)
		graph_node.owner = get_scene()
	
	_graph_edit.connect("node_selected", _on_graph_node_selected)


func _get_all_resources() -> Array[Resource]:
	var resources: Array[Resource] = []
	
	var dir = Directory.new()
	dir.include_hidden = false
	
	var unprocessed_dirs: Array[String] = ["res://"]
	
	while not unprocessed_dirs.is_empty():
		dir.open(unprocessed_dirs.pop_front())
		dir.list_dir_begin()
	
		while true:
			var item_path = dir.get_next()
			if item_path == "":
				break
			
			if item_path.begins_with("."):
				continue
			
			var item_full_path = dir.get_current_dir() + "/" + item_path
			if dir.current_is_dir():
				unprocessed_dirs.append(item_full_path + "/")
			elif item_path.ends_with(".tres"):
				resources.append(load(item_full_path))
		
		dir.list_dir_end()
	
	return resources


func _clear_graph_edit():
	for child in _graph_edit.get_children():
		_graph_edit.remove_child(child)


func _fill_resources_connections(resources: Array[Resource]):
	_resources_connections.clear()
	
	var resources_to_process: Array[Resource] = resources
	var processed_resources: Array[Resource] = []
	
	while not resources_to_process.is_empty():
		var resource = resources_to_process.pop_back()
		var props = _get_exported_resource_props(resource)
		
		var connections_out: Array[ResourceConnection] = []
		for prop in props:
			var prop_resource: Resource = resource[prop.name]
			
			if prop_resource == resource or prop_resource == null:
				continue
			
			connections_out.append(ResourceConnection.new(prop.name, prop_resource))
			
			if (not resources_to_process.has(prop_resource)
			and not processed_resources.has(prop_resource)):
				resources_to_process.append(prop_resource)
		
		var resource_connections := ResourceConnections.new()
		resource_connections.connections_out = connections_out
		_resources_connections[resource] = resource_connections
		
		processed_resources.append(resource)
	
	for resource in _resources_connections:
		var resource_connections: ResourceConnections = _resources_connections[resource]
		
		for connection in resource_connections.connections_out:
			var connection_in := ResourceConnection.new(connection.property, resource)
			_resources_connections[connection.resource].connections_in.append(connection_in)


func _get_exported_resource_props(resource: Resource) -> Array:
	return _get_exported_props(resource).filter(
		func(x):
			return x.hint == PROPERTY_HINT_RESOURCE_TYPE)


func _get_exported_props(resource: Resource) -> Array:
	const PROPERTY_USAGE_EXPORT: int = 8199
	var resource_script = resource.script as Script
	var props = resource_script.get_script_property_list()
	
	var filtered_props = props.filter(
		func(x):
			return x.usage == PROPERTY_USAGE_EXPORT)
	
	return filtered_props


func _create_graph_node(resource: Resource) -> GraphNode:
	var props = _get_exported_props(resource)
	var graph_node := _graph_node_tscn.instantiate()
	graph_node.setup(resource)
	
	for prop in props:
		var prop_container = _graph_node_prop_container_tscn.instantiate()
		prop_container.setup(prop, resource[prop.name])
		graph_node.add_child(prop_container)

	return graph_node


func _on_graph_node_selected(node):
	var editor_iface := get_editor_interface()
	
	editor_iface.inspect_object(node.resource)
	print(node, "selected")


class ResourceConnections:
	var connections_in: Array[ResourceConnection] = []
	var connections_out: Array[ResourceConnection] = []


class ResourceConnection:
	var property: String
	var resource: Resource
	
	
	func _init(property: String, resource: Resource):
		self.property = property
		self.resource = resource
