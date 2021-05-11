extends Node

# Guarda os estados possiveis
onready var states:Dictionary;
onready var anim_states:Dictionary
# Guarda o estado atual
var current_state:String = 'OnGround'
# Guarda o estado anterior
var prev_state:String

# Sinal para caso o estado mude
signal state_changed(old_state, new_state)

func _ready():
	# Adiciona todos os estados disponveis baseados nos nos de forma dinamica
	var children = get_children()
	for i in children:
		states[i.name] = i
	
	emit_signal('ready')

func physics_step(host:PlayerPhysics, delta):
	var state_name = states[current_state].step(host, delta)
	anim_states[current_state].animation_step(host, states[current_state], delta)
	if state_name:
		change_state(host, state_name)
	var snap_total = host.snap_vec * host.snap_margin
	host.speed = host.move_and_slide_with_snap(\
		host.speed,\
		snap_total,\
		Vector2.UP,\
		true,\
		4,\
		deg2rad(55),\
		false\
	)
	

func change_state(host, next_state):
	if next_state == current_state:
		return
	assert(states.has(next_state), "Error, state does not exist");
	states[current_state].exit(host, next_state)
	anim_states[current_state].exit(host, states[current_state], next_state)
	prev_state = current_state
	current_state = next_state
	states[next_state].enter(host, prev_state)
	anim_states[current_state].enter(host, states[current_state], prev_state)
	emit_signal("state_changed", prev_state, current_state)

func is_state(name:String) -> bool:
	return current_state == name

func _on_Animator_animation_finished(anim_name):
	anim_states[current_state].on_Animator_animation_finished(anim_name, states[current_state], owner)

func _on_Animator_change_animation(prev_name, next_name, current_time):
	anim_states[current_state].on_Animator_animation_changed(prev_name, next_name, current_time, owner, self)

func get_current_state() -> State:
	return states[current_state]

func get_current_anim_state() -> AnimState:
	return anim_states[current_state]

func _on_Player_ready() -> void:
	anim_states = owner.sel_char.get_node("AnimStates").states
