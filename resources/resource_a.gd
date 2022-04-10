class_name ResourceA
extends Resource


@export var a: Resource = a as ResourceA
@export var ab: Resource = a as ResourceA
@export var b: int
@export var c: int


func get_class() -> String:
	return "ResourceA"
