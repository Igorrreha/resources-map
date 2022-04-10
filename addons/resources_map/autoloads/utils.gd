@tool

extends Node


func get_exported_props(resource: Resource) -> Array:
	const PROPERTY_USAGE_EXPORT: int = 8199
	var resource_script = resource.script as Script
	var props = resource_script.get_script_property_list()
	
	var filtered_props = props.filter(
		func(x):
			return x.usage == PROPERTY_USAGE_EXPORT)
	
	return filtered_props
