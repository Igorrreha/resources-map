@tool
extends HBoxContainer


@export_node_path(Label) var _name_label_path
@export_node_path(Label) var _value_label_path
var _name_label: Label
var _value_label: Label 


func setup(property: Dictionary, value):
	_name_label = get_node(_name_label_path)
	_value_label = get_node(_value_label_path)
	
	_name_label.text = property.name
	set_value(value)


func set_value(value):
	_value_label.text = _get_value_string(value)


func _get_value_string(value) -> String:
	return (ResourcesMapUtils.get_resource_name(value)
		if value is Resource
		else str(value))
