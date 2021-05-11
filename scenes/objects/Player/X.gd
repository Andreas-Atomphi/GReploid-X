extends PlayerProps
var speed_pattern:Vector2 = Vector2(160.0, 10.0)
var dash_speed:float = 350
var shoot_normal : float = 0.4
var shoot_timer : float = 0.0
var shoots : Array = [
	preload("res://scenes/objects/Player/LemonShoot.tscn")
]
var shoots_on_screen:Array = []
onready var main_props: Dictionary = {
	sprite = $Sprite,
	animator = $Sprite/Animator,
	shoot_pos = $Sprite/ShootSpawner,
	particle = $Sprite/DashParticles,
}
onready var ladder_sensor : RayCast2D = $LadderSensor
const MAX_SHOOTS:int = 3

func _ready() -> void:
	set_process(false)

func attack(shoot:int):
	#print(selector.scale.x)
	assert(shoots.size() >= shoot, "Index not found")
	var shoot_obj:KinematicBody2D = shoots[shoot].instance()
	var shoot_pos = host.char_props.shoot_pos.global_position.x
	shoot_obj.add_collision_exception_with(self)
	shoot_obj.scale.x = Utils.int_bin(shoot_pos > host.global_position.x)
	shoot_obj.global_position = host.char_props.shoot_pos.global_position
	shoot_obj.shoot_owner = self
	host.get_parent().add_child(shoot_obj)
	shoots_on_screen.append(shoot_obj)
	for i in shoots_on_screen:
		var obj : KinematicBody2D = i
		for j in shoots_on_screen:
			var exc : KinematicBody2D = j
			obj.add_collision_exception_with(exc)
	return shoot_obj

func input_proc(event, host:PlayerPhysics):
	var dict:Dictionary = host.inputs;
	dict.shoot = false
	if shoots_on_screen.size() < MAX_SHOOTS:
		dict["shoot"] = Input.is_action_just_pressed("ui_shoot")
		if dict.shoot:
			var animator : CharacterAnimator = host.char_props.animator
			if !is_processing():
				set_process(true)
			if host.fsm.is_state("OnGround") &&\
				(host.fsm.get_current_anim_state().main_anim_name == "Idle" ||\
				 host.fsm.get_current_anim_state().main_anim_name == "IdleBlink" ||\
				 host.fsm.get_current_anim_state().main_anim_name == "StopShoot"):
				if animator.is_playing():
					animator.seek(0.0)
				else:
					animator.animate("StopShoot", 1.0, false)
			elif host.fsm.is_state("StairClimb"):
				if host.fsm.get_current_anim_state().main_anim_name != "LadderShoot":
					host.fsm.get_current_anim_state().main_anim_name = "LadderShoot"
					animator.animate(host.fsm.get_current_anim_state().main_anim_name, 1.0, false)
				else:
					if animator.is_playing():
						animator.seek(0.0)
			host.attacking = true
			shoot_timer = shoot_normal
			attack(0).connect("exited", self, "remove_shoot")
	return dict

func _process(delta:float):
	if host.attacking && shoot_timer > 0.0:
		shoot_timer -= delta
	else:
		host.attacking = false
		set_process(false)
	
	

func remove_shoot(obj:KinematicBody2D) -> void:
	var pos = shoots_on_screen.find(obj)
	shoots_on_screen.remove(pos)
