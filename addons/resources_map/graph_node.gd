@tool

class_name ResourceGraphNode
extends GraphNode


var resource: Resource

var _graph_node_prop_container_tscn := preload("res://addons/resources_map/graph_node_prop_container.tscn")
var _props_slots_idxs: Dictionary = {}
var _props_containers: Dictionary = {}


func setup(resource: Resource):
	self.resource = resource
	
	name = str(resource)
	title = ResourcesMapUtils.get_resource_name(resource)
	
	var props = ResourcesMapUtils.get_exported_props(resource)
	var last_slot_idx := 0
	var last_out
	
	for i in range(props.size()):
		var prop = props[i]
		var prop_container = _create_property_container(prop)
		add_child(prop_container)
		last_slot_idx += 1
		
		_props_containers[prop.name] = prop_container
		
		if prop.hint == PROPERTY_HINT_RESOURCE_TYPE:
			set_slot(last_slot_idx, false, prop.type, Color.LIME_GREEN,
				true, prop.type, Color.LIME_GREEN)
			
			_props_slots_idxs[prop.name] = get_connection_output_count() - 1


func update_properties_values():
	for prop_name in _props_containers:
		_props_containers[prop_name].set_value(resource[prop_name])


func get_property_slot_idx(property_name: String):
	return _props_slots_idxs[property_name]


func get_main_slot_idx():
	return 0


func _create_property_container(prop) -> Control:
	var prop_container = _graph_node_prop_container_tscn.instantiate()
	prop_container.setup(prop, resource[prop.name])
	
	return prop_container

