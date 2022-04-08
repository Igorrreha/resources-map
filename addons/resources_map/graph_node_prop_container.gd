@tool
extends HBoxContainer


@export_node_path(Label) var _label_path


func setup(property: Dictionary):
	var label = get_node(_label_path) as Label
	label.text = property.name


func _create_input_control_for_prop(prop) -> Control:
	match prop.type:
		TYPE_INT:
			var control = SpinBox.new()
			
			
			
		TYPE_FLOAT:
			pass
		TYPE_COLOR:
			pass
		TYPE_OBJECT:
			pass
	
	var control = Label.new()
	control.text = prop.name
	return 
