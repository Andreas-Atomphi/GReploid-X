extends Node2D
tool
signal Change_char(path)
onready var host = get_owner()
var chars:Array

func _enter_tree() -> void:
	if Engine.editor_hint:
		var c = get_children()
		for i in c:
			if i.is_class("PlayerProps"):
				chars[i] = c[i]
		emit_signal('tree_entered')

func _ready() -> void:
	if !Engine.editor_hint:
		var c = get_children()
		for i in c.size():
			if i.is_class("PlayerProps"):
				chars[i] = c[i]
		emit_signal('ready')
