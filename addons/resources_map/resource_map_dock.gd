@tool

class_name ResourceMapDock
extends Control


func setup(resource: Resource):
	var props = resource.get_property_list()
	
	props.filter(func(x): x.usage == "PROPERTY_USAGE_SCRIPT_VARIABLE")
	print(props)
