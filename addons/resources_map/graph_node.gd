@tool

class_name ResourceGraphNode
extends GraphNode


var resource: Resource

var _graph_node_prop_container_tscn := preload("res://addons/resources_map/graph_node_prop_container.tscn")
var _props_slots_idxs: Dictionary = {}
var _slots_idxs_props: Dictionary = {}
var _right_slots_global_idxs: Dictionary = {}
var _props_containers: Dictionary = {}


func setup(resource: Resource):
	self.resource = resource
	
	name = str(resource)
	title = ResourcesMapUtils.get_resource_name(resource)
	
	var props = ResourcesMapUtils.get_exported_props(resource)
	var last_slot_idx := 0
	var last_out_slot_idx := -1
	
	for i in range(props.size()):
		var prop = props[i]
		var prop_container = _create_property_container(prop)
		add_child(prop_container)
		last_slot_idx += 1
		_props_containers[prop.name] = prop_container
		
		if prop.hint == PROPERTY_HINT_RESOURCE_TYPE:
			last_out_slot_idx += 1
			_right_slots_global_idxs[last_out_slot_idx] = last_slot_idx
			
			set_slot(last_slot_idx, false, TYPE_OBJECT, Color.LIME_GREEN,
				true, TYPE_OBJECT, Color.LIME_GREEN)
			
			prop_container.clear_slot.connect(set_property_in_slot.bind(last_out_slot_idx, null))
			
			_props_slots_idxs[prop.name] = last_out_slot_idx
			_slots_idxs_props[last_out_slot_idx] = prop.name


func update_properties_values():
	for prop_name in _props_containers:
		_props_containers[prop_name].set_value(resource[prop_name])


func get_property_slot_idx(property_name: String):
	return _props_slots_idxs[property_name]


func get_main_slot_idx():
	return 0


func get_right_slot_global_idx(slot_local_idx: int):
	return _right_slots_global_idxs[slot_local_idx]


func set_property_in_slot(slot_idx: int, value):
	resource[_slots_idxs_props[slot_idx]] = value


func _create_property_container(prop) -> Control:
	var prop_container = _graph_node_prop_container_tscn.instantiate()
	prop_container.setup(prop, resource[prop.name])
	
	return prop_container


func _gui_input(event):
	event = event as InputEventMouseButton
	if not event:
		return
	
	if event.double_click:
		ResourcesMapEvents.resource_node_dblclicked.emit(self)
