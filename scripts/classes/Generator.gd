extends Node2D
tool

export(PackedScene) var pack:PackedScene
export var x:int = 0 setget set_x, get_x
export var y:int = 0 setget set_y, get_y
export var size:Vector2
export(bool) var erase setget click_erase

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func click_erase(value):
	set_x(0)
	set_y(0)
	pass

func set_x(val:int) -> void:
	x = val
	update()

func get_x() -> int:
	return x

func set_y(val:int) -> void:
	y = val
	update()

func get_y() -> int:
	return y

func draw_grid() -> void:
	if !pack:
		return
	var all: Node2D = Node2D.new()
	all.position = Vector2.ZERO
	add_child(all)
	for i in x:
		for j in y:
			var pack_instance:Node2D = pack.instance(PackedScene.GEN_EDIT_STATE_INSTANCE)
			pack_instance.position = Vector2(i, j) * size
			all.add_child(pack_instance)

func update() -> void:
	var children = get_children()
	if children.size() > 0:
		for i in children:
			i.queue_free()
	draw_grid()
