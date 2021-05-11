extends Node

class_name AnimState

func enter(host:PlayerPhysics, main_state:State, prev_state:String):
	pass

func exit(host:PlayerPhysics, main_state:State, next_state:String):
	pass

func animation_step(host:PlayerPhysics, main_state:State,delta:float):
	pass

func on_Animator_animation_finished(anim_name:String, main_state:State, host:PlayerPhysics):
	pass

func on_Animator_animation_changed(prev_name:String, next_name:String, current_time:float, host:PlayerPhysics, main_state:State):
	pass
