@tool
extends HBoxContainer


signal clear_slot

@export_node_path(Label) var _name_label_path
@export_node_path(Label) var _value_label_path
@export_node_path(Button) var _clear_slot_btn_path
var _name_label: Label
var _value_label: Label
var _clear_slot_btn: Button


func setup(property: Dictionary, value):
	_name_label = get_node(_name_label_path)
	_value_label = get_node(_value_label_path)
	_clear_slot_btn = get_node(_clear_slot_btn_path) as Button
	
	_name_label.text = property.name
	
	set_value(value)


func set_value(value):
	_value_label.text = _get_value_string(value)
	_clear_slot_btn.visible = value is Object


func _get_value_string(value) -> String:
	return (ResourcesMapUtils.get_resource_name(value)
		if value is Resource
		else str(value))


func _on_clear_slot_btn_pressed():
	clear_slot.emit()
