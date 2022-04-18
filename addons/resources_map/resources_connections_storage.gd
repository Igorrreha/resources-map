@tool

class_name ResourcesConnectionsProvider


signal connections_changed(resource)


var _resources_connections: Dictionary # {Resource, Array[ResourceConnection]}


func get_all_connected_resources() -> Array[Resource]:
	return _resources_connections.keys()


func get_out_connections(resource: Resource) -> Array:
	return _resources_connections[resource].connections_out


func _init(resources: Array[Resource]):
	_fill_resources_connections(resources)
	
	for resource in _resources_connections:
		resource.changed.connect(_update_connections.bind(resource))


func _fill_resources_connections(resources: Array[Resource]):
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


func _update_connections(resource: Resource):
	var props = _get_exported_resource_props(resource)
	var connections_out = _resources_connections[resource].connections_out
	
	var dirty := false
	
	var props_has_connection := {}
	for prop in props:
		props_has_connection[prop.name] = false
	
	for connection in connections_out:
		var old_value = connection.resource
		var new_value = resource[connection.property]
		
		props_has_connection[connection.property] = true
		
		if old_value == new_value:
			continue
		
		dirty = true
		
		if old_value:
			var connections_in: Array = _resources_connections[old_value].connections_in
			var old_connection = connections_in.filter(func(x):
				return (x.resource == resource
				and x.property == connection.property))[0]
			connections_in.erase(old_connection)
		
		if new_value:
			var new_connection = ResourceConnection.new(connection.property, resource)
			_resources_connections[new_value].connections_in.append(new_connection)
		
		connection.resource = new_value
	
	for prop in props_has_connection:
		var prop_value = resource[prop]
		
		if (props_has_connection[prop]
		or prop_value == null):
			continue
		
		dirty = true
		
		var new_connection_out = ResourceConnection.new(prop, prop_value)
		_resources_connections[resource].connections_out.append(new_connection_out)
		
		var new_connection_in = ResourceConnection.new(prop, resource)
		_resources_connections[prop_value].connections_in.append(new_connection_in)
	
	if dirty:
		connections_changed.emit(resource)


class ResourceConnections:
	var connections_in: Array[ResourceConnection] = []
	var connections_out: Array[ResourceConnection] = []


class ResourceConnection:
	var property: String
	var resource: Resource
	
	
	func _init(property: String, resource: Resource):
		self.property = property
		self.resource = resource
