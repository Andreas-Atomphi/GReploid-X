extends Node

static func _action_s(ui:String) -> float:
	return Input.get_action_strength(ui);

static func input_direction():
	return Vector2(\
	- _action_s("ui_left") + _action_s("ui_right"),\
	- _action_s("ui_up") + _action_s("ui_down"))
