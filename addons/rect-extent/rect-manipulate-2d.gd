tool
extends Node2D

class_name RectManipulate2D

export var fill:bool setget set_fill
export var size:Vector2 = Vector2(40, 40) setget set_size
export var color:Color = Color(1.0, 0, 0, 0.7) setget set_color
export var offset:Vector2 = Vector2(0, 0) setget set_offset

var _rect:Rect2

func _enter_tree() -> void:
	if Engine.editor_hint:
		update()

func set_fill (val: bool) -> void:
	fill = val
	update()

func set_color(val:Color) -> void:
	color = val
	update()

func set_size(val:Vector2) -> void:
	size = val
	_recalculate_rect()
	update()
	
func set_offset(val:Vector2) -> void:
	offset = val
	_recalculate_rect()
	update()

func _recalculate_rect():
	_rect = Rect2(-1.0 * size / 2 + offset, size)

func _draw() -> void:
	if !Engine.editor_hint:
		return
	draw_rect(_rect, color, fill)

func has_point(point:Vector2) -> bool:
	var rect_global = Rect2(global_position + _rect.position, _rect.size)
	return rect_global.has_point(point)

func get_rectshape_2d() -> Dictionary:
	var rect := RectangleShape2D.new();
	rect.extents = size/2
	return {
		shape = rect,
		position = position + offset
	}
