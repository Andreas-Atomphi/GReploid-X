extends Node2D
class_name PlayerProps

onready var sprite = $Sprites
onready var host:PlayerPhysics = get_owner()
onready var selector : = get_parent()
export var gradient:Gradient

func get_class() -> String:
	return "PlayerProps"

func is_class(name:String) -> bool:
	return .is_class(name) || name == get_class()
