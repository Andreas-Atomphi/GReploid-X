tool
extends Node2D
# Author: Luiz Lopes (youtube.com/CanalPalco)
# License: MIT
#
# Add a trail of copies of the parent's texture.
#
# Usage: put as a child of Sprite or Animated Sprite and tweek the settings in
# the inspector.
#
# Implementation
# The `_trail_copies` variable has information about the copies as dictionaries
# in the following format:
# {
#     global_position, # (Vector2) The global position of this copy
#     texture, # (Texture) A reference to the texture used in this copy
#     remaining_time, # (float) Remaining time until it disappears
#     transform_scale, # (Vector2) x = -1 if flip_h and y = -1 if flip_v, else both = 1
# }
#
# This works by using `draw_texture` method to draw copies of the parent's
# texture. If it is an AnimatedSprite it records the current frame's texture.
# There is a problem when flipping the sprite, the flipping doesn't occur when
# calling `draw_texture`. So there is a work-arround setting the draw_scale as
# -1 and then correcting the positions for the new transform.

enum ProcessMode {PROCESS, PHYSICS_PROCESS}
export var sprite_path:NodePath setget set_sprite_path, get_sprite_path
var _sprite_node : Node2D
export var active: = false setget set_active
export var by_scale: bool
export var life_time: = 0.6
export var fake_velocity: = Vector2(0, 0)
export var copy_period: = 0.2
export var gradient: Gradient
export var behind_parent: = true setget set_behind_parent
export (ProcessMode) var process_mode: int = ProcessMode.PROCESS setget set_process_mode
export var solid_color:bool = false

var _trail_copies: = []
var _elapsed_time: = 0.0


func _ready() -> void:
	show_behind_parent = behind_parent
	set_process_mode(process_mode)

func is_sprite_type(obj:Node):
	return obj is AnimatedSprite || obj is Sprite

func _enter_tree():
	var parent = get_parent()
	if !is_sprite_type(parent):
		var bros = parent.get_children()
		for i in bros:
			if is_sprite_type(i):
				sprite_path = i.get_path()
				_sprite_node = get_node(sprite_path)
				break
	else:
		sprite_path = get_parent().get_path()
	
	if has_node(sprite_path):
		_sprite_node = get_node(sprite_path)

func _process(delta: float) -> void:
	update_trail(delta, _sprite_node)


func _physics_process(delta: float) -> void:
	update_trail(delta, _sprite_node)


func _draw() -> void:
	for i in _trail_copies:
		var copy: Dictionary = i
		# We need to correct the direction if the scale is set to -1, see
		# spawn_copy method.
		var draw_translation: Vector2 = to_local(copy.global_position) * copy.transform_scale;
		if _sprite_node.centered:
			draw_translation -= copy.texture.get_size() / 2.0
		
		var draw_transform = Transform2D(\
			0.0,\
			position\
		)\
		.scaled(copy.transform_scale) \
		.translated(draw_translation)
		
		#print(copy.offset)
		
		var final_color:Color = calculate_copy_color(copy)
		draw_set_transform_matrix(draw_transform)
		draw_texture(
			copy.texture,
			position + copy.offset * Vector2(-1, 1),
			final_color
		)



func process_copies(delta: float) -> void:
	var empty_copies: = _trail_copies.empty()

	for copy in _trail_copies:
		copy.remaining_time -= delta

		if copy.remaining_time <= 0:
			_trail_copies.erase(copy)
			continue

		copy.global_position -= fake_velocity * delta

	if not empty_copies:
		update()


func get_texture(sprite: Node2D) -> Texture:
	match sprite.get_class():
		"Sprite":
			return sprite.texture
		"AnimatedSprite":
			return sprite.frames.get_frame(sprite.animation, sprite.frame)
		
	push_error("The SpriteTrail has to have a Sprite or an AnimatedSpriet as parent.")
	set_active(false)
	return null


func calculate_copy_color(copy: Dictionary) -> Color:
	if gradient:
		return gradient.interpolate(range_lerp(copy.remaining_time, 0, life_time, 0, 1))

	return Color(1, 1, 1)


func spawn_copy(delta: int, parent: Node2D) -> void:
	var copy_texture: = get_texture(parent)
	var copy_position: Vector2
	var copy_offset: Vector2
	match parent.get_class():
		"Sprite":
			var sprite :Sprite = parent
			copy_offset = sprite.offset
		"AnimatedSprite":
			var anim_sprite:AnimatedSprite = parent
			copy_offset = anim_sprite.offset
	
	if not copy_texture:
		return

	if parent.centered:
		copy_position = parent.global_position
	else:
		copy_position = parent.global_position

	# This is needed because the draw transform's scale is set to -1 on the flip
	# direction when the sprite is flipped
	var transform_scale:Vector2
	if !by_scale:
		transform_scale.x = Utils.int_bin(!parent.flip_h)
		transform_scale.y = Utils.int_bin(!parent.flip_v)
	else:
		transform_scale = parent.get_parent().get_parent().scale * Vector2(Utils.int_bin(!parent.flip_h), Utils.int_bin(!parent.flip_v))
	var trail_copy: = {
		global_position = copy_position,
		texture = copy_texture,
		remaining_time = life_time,
		transform_scale = transform_scale,
		offset = copy_offset,
	}
	_trail_copies.append(trail_copy)


func update_trail(delta: float, parent: Node2D) -> void:
	if active:
		_elapsed_time += delta

	process_copies(delta)

	if _elapsed_time > copy_period and active:
		spawn_copy(delta, parent)
		_elapsed_time = 0.0


func set_active(value: bool) -> void:
	active = value


func set_behind_parent(value: bool) -> void:
	behind_parent = value
	show_behind_parent = behind_parent


func set_process_mode(value: int) -> void:
	process_mode = value

	set_process(process_mode == ProcessMode.PROCESS)
	set_physics_process(process_mode == ProcessMode.PHYSICS_PROCESS)


func _get_configuration_warning() -> String:
	if not has_node(sprite_path):
		return "There's not have sprites or animated sprites on the actual scope"

	return ""

func set_sprite_path(val:NodePath):
	sprite_path = val
	_sprite_node = get_node(sprite_path)

func get_sprite_path() -> NodePath:
	return sprite_path

func get_class() -> String:
	return "SpriteTrail"

func is_class(name:String) -> bool:
	return .is_class(name) || name == get_class()
