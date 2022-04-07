@tool
extends EditorPlugin


var _dock: ResourceMapDock
var _dock_tscn = preload("res://addons/resources_map/resource_map_dock.tscn")
var _inspector_plugin: EditorInspectorPlugin


func _enter_tree():
	var resource = preload("res://resources/resource_a.gd").new()
	
	_dock = _dock_tscn.instantiate() as ResourceMapDock
	_dock.minimum_size.y = 300
	_dock.setup(resource)
	add_control_to_bottom_panel(_dock, "Resources Map")
	make_bottom_panel_item_visible(_dock)


func _exit_tree():
	remove_control_from_bottom_panel(_dock)
	_dock.queue_free()
