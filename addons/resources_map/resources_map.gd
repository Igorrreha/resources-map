@tool
extends EditorPlugin


var _dock_tscn = preload("res://addons/resources_map/resource_map_dock.tscn")
var _dock: ResourceMapDock

var _graph_edit: GraphEdit
var _resources_connections: Dictionary # {Resource, Array[ResourceConnection]}


func _enter_tree():
	var resources: Array[Resource] = _get_all_resources()
	_fill_resources_connections(resources)
	
	ResourcesMapEvents.connect("resource_node_selected", _on_resource_node_selected)
	_dock = _dock_tscn.instantiate() as ResourceMapDock
	_dock.minimum_size.y = 300
	
	_dock.setup(_resources_connections.keys())
	add_control_to_bottom_panel(_dock, "Resources Map")
	make_bottom_panel_item_visible(_dock)


func _exit_tree():
	ResourcesMapEvents.disconnect("resource_node_selected", _on_resource_node_selected)
	remove_control_from_bottom_panel(_dock)
	_dock.queue_free()


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
	return ResourcesMapUtils.get_exported_props(resource).filter(
		func(x):
			return x.hint == PROPERTY_HINT_RESOURCE_TYPE)


func _on_resource_node_selected(node):
	var editor_iface := get_editor_interface()
	var resource = node.resource
	
	editor_iface.inspect_object(resource)
	editor_iface.get_file_system_dock().navigate_to_path(resource.resource_path)


class ResourceConnections:
	var connections_in: Array[ResourceConnection] = []
	var connections_out: Array[ResourceConnection] = []


class ResourceConnection:
	var property: String
	var resource: Resource
	
	
	func _init(property: String, resource: Resource):
		self.property = property
		self.resource = resource
