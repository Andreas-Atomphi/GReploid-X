extends Area2D
class_name Ladder
tool

var collision_disabled = false setget _set_coll_disabled

func _enter_tree() -> void:
	update_configuration_warning()

func _ready() -> void:
	if !Engine.editor_hint:
		connect('body_entered', self, "_on_Ladder_body_entered")
		connect('body_exited', self, "_on_Ladder_body_exited")
		for i in get_children():
			if i is Area2D:
				var a2d : Area2D = i
				if a2d.get_signal_connection_list("body_entered") == []:
					a2d.connect('body_entered', self, "_on_TopSensor_body_entered")
				if a2d.get_signal_connection_list("body_exited") == []:
					a2d.connect('body_exited', self, "_on_TopSensor_body_exited")

func _on_Ladder_body_entered(body: Node) -> void:
	if !Engine.editor_hint:
		if body.is_class("PlayerPhysics"):
			var player:PlayerPhysics = body
			player.current_ladder = self


func _on_Ladder_body_exited(body: Node) -> void:
	if !Engine.editor_hint:
		if body.is_class("PlayerPhysics"):
			var player:PlayerPhysics = body
			_set_coll_disabled(false)
			if player.current_ladder == self:
				player.current_ladder = null

func _on_TopSensor_body_entered(body : Node) -> void:
	if !Engine.editor_hint:
		if body.is_class("PlayerPhysics"):
			var player : PlayerPhysics = body
			player.current_ladder_top = self

func _on_TopSensor_body_exited(body : Node) -> void:
	if !Engine.editor_hint:
		if body.is_class("PlayerPhysics"):
			var player : PlayerPhysics = body
			if player.current_ladder_top == self:
				player.current_ladder_top = null

func _set_coll_disabled(val:bool) -> void:
	collision_disabled = val
	for i in get_children():
		if i is StaticBody2D:
			var static_b : StaticBody2D = i
			for j in static_b.get_children():
				if j is CollisionShape2D:
					j.disabled = val
					j.set_deferred("disabled", val)

func _get_configuration_warning() -> String:
	var children = get_children()
	var message: String = ""
	var has_static_body = false
	var has_area2D = false
	for i in children:
		if i is StaticBody2D:
			has_static_body = true
		if i is Area2D:
			has_area2D = true

	
	if !has_area2D:
		message += "Este no deve conter um filho do tipo Area2D para identificar o topo"
	
	if !has_static_body:
		message += "\nEste no deve conter um filho do tipo StaticBody2D"
	
	return message
