@tool

class_name ResourceA
extends Resource


@export var a: Resource = a as ResourceA:
	set(v):
		a = v
		emit_changed()
@export var ab: Resource = a as ResourceA:
	set(v):
		ab = v
		emit_changed()
@export var b: int:
	set(v):
		b = v
		emit_changed()
@export var c: int:
	set(v):
		c = v
		emit_changed()


func get_class() -> String:
	return "ResourceA"
