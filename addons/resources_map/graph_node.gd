@tool

class_name ResourceGraphNode
extends GraphNode


var resource: Resource

var _graph_node_prop_container_tscn := preload("res://addons/resources_map/graph_node_prop_container.tscn")
var _props_slots: Dictionary = {}


func setup(resource: Resource):
	self.resource = resource
	
	name = str(resource)
	title = _get_resource_name(resource)
	
	var props = ResourcesMapUtils.get_exported_props(resource)
	var last_slot_idx := 0
	var last_out
	
	for i in range(props.size()):
		var prop = props[i]
		var prop_slot = _create_property_slot(resource, prop)
		add_child(prop_slot)
		last_slot_idx += 1
		
		if prop.hint == PROPERTY_HINT_RESOURCE_TYPE:
			set_slot(last_slot_idx, false, prop.type, Color.LIME_GREEN,
				true, prop.type, Color.LIME_GREEN)
			
			_props_slots[prop.name] = get_connection_output_count() - 1


func get_property_slot_idx(property_name: String):
	return _props_slots[property_name]


func get_main_slot_idx():
	return 0


func _create_property_slot(resource: Resource, prop) -> Control:
	var prop_container = _graph_node_prop_container_tscn.instantiate()
	var prop_value = resource[prop.name]
	var string_value = (_get_resource_name(prop_value)
		if prop_value is Resource
		else str(prop_value))
	prop_container.setup(prop, string_value)
	
	return prop_container


func _get_resource_name(resource: Resource):
	return (resource.resource_path.get_file()
		if resource.resource_name.is_empty()
		else resource.resource_name)
