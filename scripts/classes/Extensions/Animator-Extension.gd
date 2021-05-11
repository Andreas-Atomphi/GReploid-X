extends AnimationPlayer

class_name CharacterAnimator

signal change_animation(prev_name, next_name, current_time)

var previous_animation : String

func animate(animation_name : String, custom_speed : float, can_loop : bool, from : float = -1, from_end:bool = false):
	if can_loop and animation_name == previous_animation:
		return
	var current_time = current_animation_position
	
	play(animation_name, -1, custom_speed, from_end)
	emit_signal("change_animation", previous_animation, animation_name, current_time)
	if from >= 0.0:
		if current_animation_length >= current_animation_position:
			seek(from, true)
	previous_animation = animation_name
