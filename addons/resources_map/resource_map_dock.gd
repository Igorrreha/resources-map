@tool

class_name ResourceMapDock
extends Control


@export_node_path(GraphEdit) var _graph_edit_path: NodePath
@onready var _graph_edit = get_node(_graph_edit_path)


var _graph_node_tscn := preload("res://addons/resources_map/graph_node.tscn")
var _resources: Array[Resource]
var _resources_nodes: Dictionary


func setup(resources: Array):
	_resources = resources


func _init():
	ResourcesMapEvents.connect("node_connections_requested", _on_node_connections_requested)
	ResourcesMapEvents.connect("all_nodes_connections_created", _on_all_nodes_connections_created)


func _ready():
	_graph_edit.connect("node_selected", func(node):
		ResourcesMapEvents.emit_signal("resource_node_selected", node))
	
	for resource in _resources:
		var node := _create_graph_node(resource)
		_graph_edit.add_child(node)
		_resources_nodes[resource] = node
	
	ResourcesMapEvents.emit_signal("graph_nodes_created")


func _create_graph_node(resource: Resource) -> GraphNode:
	var graph_node := _graph_node_tscn.instantiate()
	graph_node.setup(resource)
	
	return graph_node


func _on_node_connections_requested(resource: Resource, connections: Array):
	if not _resources_nodes.has(resource):
		return
	
	var node_from: ResourceGraphNode = _resources_nodes[resource]
	for connection in connections:
		var slot_from_idx = node_from.get_property_slot_idx(connection.property)
		var node_to: ResourceGraphNode = _resources_nodes[connection.resource]
		var slot_to_idx = node_to.get_main_slot_idx()
		_graph_edit.connect_node(node_from.name, slot_from_idx, node_to.name, slot_to_idx)


func _on_all_nodes_connections_created():
	for child in _resources_nodes.values():
		child.selected = true
	
	_graph_edit.arrange_nodes()
	
	for child in _resources_nodes.values():
		child.selected = false
