extends KinematicBody2D
class_name PlayerPhysics
signal char_changed (host)
# Valores da parede quem que esta colidindo
enum Wall {LEFT, RIGHT}
export var current_char:int = 0 setget set_c_char, get_c_char

onready var global:Global = $"/root/Global"
onready var chars:Node2D = $Characters
# Guarda o personagem selecionado
onready var sel_char:Node2D

# Guarda o Sprite trail
onready var post_images:= get_node("DashTrail")

#Guarda as propriedades do personagem selecionado
var char_props

# Guarda a maquina de estados
onready var fsm = $FSM

#onready var left_wall:= $LeftWall
#onready var right_wall:= $RightWall
#onready var left_wall_top:= $LeftWallTop
#onready var right_wall_top:= $RightWallTop
#onready var left_wall_bottom:= $LeftWallBottom
#onready var right_wall_bottom:= $RightWallBottom
onready var colls = {
	stand = $StandColl,
	dash = $DashColl,
	left = $Left,
	right = $Right,
}

var current_ladder
var current_ladder_top

var attacking:bool = false
var snap_margin:int = 32
var snap_vec:Vector2 = Vector2.DOWN

var speed:Vector2 = Vector2.ZERO
var grav_limit:float = 2400
var jump_speed = 300
var grounded:bool
var jumping:bool
var dashing:= false setget set_dash, get_dash
var jump_from_wall:= false
var dash_grnd_air:= false
var inputs = {
	shoot = false
};
var direction: Vector2;

func _ready():
	if !Engine.editor_hint:
		print(get_c_char())
		set_c_char(get_c_char())
		set_physics_process(true)
		set_process_input(true)
	emit_signal('ready')
	

#func ray_on_wall():
#	var l_col = left_wall.is_colliding() || left_wall_bottom.is_colliding() || left_wall_top.is_colliding()
#	var r_col = right_wall.is_colliding() || right_wall_bottom.is_colliding() || right_wall_top.is_colliding()
#	
#	return r_col || l_col

func _physics_process(delta):
	direction = global.input_direction()
	grounded = is_on_floor()
	# Executa a funcao a cada frame
	fsm.physics_step(self, delta)
	#print(is_on_wall(), get_which_wall_collided())
	
	# Limita a velocidade vertical
	speed.y = min(speed.y, grav_limit)
	
	if dashing && grounded:
		colls.dash.disabled = false
		colls.stand.disabled = true
	else:
		colls.dash.disabled = true
		colls.stand.disabled = false

func get_which_wall_collided():
	#Retorna em que lado do personagem esta tendo colisao
	var direction = 0;
	var left_chil = [$LeftMid, $LeftTop, $LeftBottom]
	var right_chil = [$RightMid, $RightTop, $RightBottom]
	var bools = [false, false]
	
	for i in left_chil:
		if i.is_colliding():
			bools[0] = true
			break
	
	for i in right_chil:
		if i.is_colliding():
			bools[1] = true
			break
	
	direction = Utils.int_tern(bools[0], bools[1])
	
	return {
		direc = direction,
		left = bools[0],
		right = bools[1]
	}

# Setter do dash, para facilitar nos efeitos
func set_dash(value:bool):
	dashing = value
	post_images.active = dashing
	char_props.particle.emitting = value

# Getter do dash
func get_dash():
	return dashing

func set_c_char(val:int) -> void:
	var old = current_char
	current_char = val
	if !chars:
		return
	var ch = chars.get_children()
	if ch.size() > 0:
		current_char = val % ch.size()
		if current_char < 0:
			current_char = ch.size() - 1
		for i in ch:
			i.visible = false
		sel_char = ch[current_char]
		sel_char.visible = true
		char_props = sel_char.main_props
		post_images.gradient = sel_char.gradient
		post_images.sprite_path = char_props.sprite.get_path()
		if old != current_char:
			emit_signal('char_changed', self)
		var rect2dStand = ch[val].get_node("StandBox").get_rectshape_2d()
		var rect2dDash = ch[val].get_node("DashBox").get_rectshape_2d()
		colls.stand.shape = rect2dStand.shape
		colls.dash.shape = rect2dDash.shape
		colls.stand.position = rect2dStand.position
		colls.dash.position = rect2dDash.position
		return
	
	current_char = 0
	print(current_char)

func get_c_char() -> int:
	return current_char
	pass

# Funçao executada
func _on_Characters_Change_char(path:NodePath):
	sel_char = chars.get_node(path)

func get_class():
	.get_class()
	return "PlayerPhysics"

func is_class(arg:String):
	return arg == get_class()

func _input (event):
	# executa a funçao input_proc da maquina de estados
	inputs = sel_char.input_proc(event, self);
