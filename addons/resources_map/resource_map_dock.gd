@tool

class_name ResourceMapDock
extends Control


func setup(resource: Resource):
	var props = resource.get_property_list()
	
	props.filter(func(x): x.hint_string == "Resource")
	print(props)
