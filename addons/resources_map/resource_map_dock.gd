@tool

class_name ResourceMapDock
extends Control


@export_node_path(GraphEdit) var _graph_edit_path: NodePath
@onready var _graph_edit = get_node(_graph_edit_path)


var _graph_node_prop_container_tscn := preload("res://addons/resources_map/graph_node_prop_container.tscn")
var _graph_node_tscn := preload("res://addons/resources_map/graph_node.tscn")

var _resources: Array[Resource]


func setup(resources: Array):
	_resources = resources


func _ready():
	_graph_edit.connect("node_selected", func(node):
		ResourcesMapEvents.emit_signal("resource_node_selected", node))
	
	for resource in _resources:
		var node := _create_graph_node(resource)
		var title = _get_resource_name(resource)
		node.title = title
		_graph_edit.add_child(node)
		node.selected = true
	
	_graph_edit.arrange_nodes()


func _create_graph_node(resource: Resource) -> GraphNode:
	var props = ResourcesMapUtils.get_exported_props(resource)
	var graph_node := _graph_node_tscn.instantiate()
	graph_node.setup(resource)
	
	var last_slot_idx := 0
	
	for i in range(props.size()):
		var prop = props[i]
		var prop_slot = _create_property_slot(resource, prop)
		graph_node.add_child(prop_slot)
		last_slot_idx += 1
		
		if prop.hint == PROPERTY_HINT_RESOURCE_TYPE:
			graph_node.set_slot(last_slot_idx, false, prop.type, Color.LIME_GREEN,
				true, prop.type, Color.LIME_GREEN)
	
	return graph_node


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
