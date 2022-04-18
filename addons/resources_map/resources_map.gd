@tool

extends EditorPlugin


var _dock_tscn = preload("res://addons/resources_map/resource_map_dock.tscn")
var _dock: ResourceMapDock

var _graph_edit: GraphEdit


func _enter_tree():
#	_connect_editor_signals()
	
	var resources: Array[Resource] = _get_all_resources()
	
	_dock = _dock_tscn.instantiate() as ResourceMapDock
	_dock.minimum_size.y = 300
	
	_dock.setup(resources)
	_dock.connect("node_selected", _on_resource_node_selected)
	
	add_control_to_bottom_panel(_dock, "Resources Map")
	make_bottom_panel_item_visible(_dock)


func _exit_tree():
#	_disconnect_editor_signals()
	_dock.disconnect("node_selected", _on_resource_node_selected)
	remove_control_from_bottom_panel(_dock)
	_dock.queue_free()


#func _connect_editor_signals():
#	var editor_iface = get_editor_interface()
#	var filesystem_dock = editor_iface.get_file_system_dock()
#	filesystem_dock.connect("file_removed", _on_file_removed)
#	var inspector = editor_iface.get_inspector()
#	inspector.connect("edited_object_changed", _on_edited_object_changed)
#	inspector.connect("property_edited", _on_property_edited)
#
#
#func _disconnect_editor_signals():
#	var editor_iface = get_editor_interface()
#	var filesystem_dock = editor_iface.get_file_system_dock()
#	filesystem_dock.disconnect("file_removed", _on_file_removed)
#	var inspector = editor_iface.get_inspector()
#	inspector.disconnect("edited_object_changed", _on_edited_object_changed)
#	inspector.disconnect("property_edited", _on_property_edited)


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
			
			var item_full_path = dir.get_current_dir().plus_file(item_path)
			if dir.current_is_dir():
				unprocessed_dirs.append(item_full_path)
			elif item_path.ends_with(".tres"):
				resources.append(load(item_full_path))
		
		dir.list_dir_end()
	
	return resources


func _on_resource_node_selected(node):
	var editor_iface := get_editor_interface()
	var resource = node.resource
	
	editor_iface.inspect_object(resource)
	editor_iface.get_file_system_dock().navigate_to_path(resource.resource_path)

#
#func _on_file_removed(file: String):
#	print("re " + file)
#func _on_edited_object_changed():
#	print(get_editor_interface().get_current_path())
#func _on_property_edited(prop: String):
#	print("property_edited " + prop)
