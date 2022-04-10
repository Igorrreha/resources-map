@tool
extends HBoxContainer


@export_node_path(Label) var _name_label_path
@export_node_path(Label) var _value_label_path


func setup(property: Dictionary, value):
	var name_label = get_node(_name_label_path) as Label
	var value_label = get_node(_value_label_path) as Label
	name_label.text = property.name
	value_label.text = str(value)
