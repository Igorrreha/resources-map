@tool

class_name ResourceMapDock
extends Control


signal node_selected(node)


@export_node_path(GraphEdit) var _graph_edit_path: NodePath

var _graph_node_tscn := preload("res://addons/resources_map/graph_node.tscn")
var _resources_nodes: Dictionary
var _resources_connections_provider: ResourcesConnectionsProvider

@onready var _graph_edit = get_node(_graph_edit_path)


func setup(resources: Array):
	_resources_connections_provider = ResourcesConnectionsProvider.new(resources)
	var all_connected_resources = _resources_connections_provider.get_all_connected_resources() 
	for resource in all_connected_resources:
		_resources_nodes[resource] = null
	
	_resources_connections_provider.connections_changed.connect(_on_resource_connections_changed)


func _ready():
	_create_graph_nodes()
	_connect_graph_nodes()
	_arrange_all_graph_nodes()
	
	_graph_edit.node_selected.connect(_on_node_selected)


func _create_graph_nodes():
	for resource in _resources_nodes:
		var graph_node := _graph_node_tscn.instantiate()
		graph_node.setup(resource)
		_graph_edit.add_child(graph_node)
		_resources_nodes[resource] = graph_node
		resource.changed.connect(_on_resource_changed.bind(resource))


func _connect_graph_nodes():
	for resource in _resources_nodes:
		var connections = _resources_connections_provider.get_out_connections(resource)
		_create_out_connections(resource, connections)


func _create_out_connections(resource: Resource, connections: Array):
	var node_from: ResourceGraphNode = _resources_nodes[resource]
	for connection in connections:
		var slot_from_idx = node_from.get_property_slot_idx(connection.property)
		var node_to: ResourceGraphNode = _resources_nodes[connection.resource]
		var slot_to_idx = node_to.get_main_slot_idx()
		_graph_edit.connect_node(node_from.name, slot_from_idx, node_to.name, slot_to_idx)


func _arrange_all_graph_nodes():
	for child in _resources_nodes.values():
		child.selected = true
	
	_graph_edit.arrange_nodes()
	
	for child in _resources_nodes.values():
		child.selected = false


func _on_node_selected(node):
	node_selected.emit(node)


func _on_resource_connections_changed(resource: Resource):
	prints("resource_connections_changed", resource)


func _on_resource_changed(resource: Resource):
	_resources_nodes[resource].update_properties_values()
