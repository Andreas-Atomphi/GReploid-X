tool
extends EditorPlugin

enum ANCHORS {
	TOP,
	RIGHT,
	TOP_LEFT,
	TOP_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_RIGHT
}

var rect_extents:RectManipulate2D
var anchors:Array
var dragged_anchor : Dictionary = {}

const CIRCLE_RADIUS : float = 4.0;
const STROKE_RADIUS : float = 1.0;
const STROKE_COLOR : Color = Color ("#ffffff")
const FILL_COLOR : Color = Color ("#f5c956")

func edit(object: Object) -> void:
	var node : Node = object
	var owner : Node = node.get_owner()
	print("edit: %s" % owner.get_path_to(node))
	rect_extents = object

func make_visible(visible: bool) -> void:
	if !rect_extents:
		return
	if !visible:
		rect_extents = null
	update_overlays()

func handles(object: Object) -> bool:
	return object is RectManipulate2D

func forward_canvas_draw_over_viewport(overlay: Control) -> void:
	if !rect_extents || !rect_extents.is_inside_tree() || !rect_extents.is_visible_in_tree():
		return
	
	var pos = rect_extents.position
	var offset = rect_extents.offset
	var half_size : Vector2 = rect_extents.size / 2.0
	var editor_anchors : = {
		ANCHORS.TOP: pos - Vector2(0, half_size.y) + offset,
		ANCHORS.RIGHT: pos - Vector2(-half_size.x, 0) + offset,
		ANCHORS.TOP_LEFT: pos - half_size + offset,
		ANCHORS.TOP_RIGHT: pos + Vector2(half_size.x, -1.0 * half_size.y) + offset,
		ANCHORS.BOTTOM_LEFT: pos + Vector2(-1.0 * half_size.x, half_size.y) + offset,
		ANCHORS.BOTTOM_RIGHT: pos + half_size + offset
	}
	var transform_viewport := rect_extents.get_viewport_transform()
	var transform_global := rect_extents.get_canvas_transform()
	anchors = []
	var anchor_size := Vector2(CIRCLE_RADIUS * 2.0, CIRCLE_RADIUS * 2.0)
	for k in editor_anchors:
		var coord = editor_anchors[k]
		var anchor_center : Vector2 = transform_viewport * (transform_global * coord)
		var new_anchor = {
			name = k,
			position = anchor_center,
			rect = Rect2(anchor_center - anchor_size / 2.0, anchor_size)
		}
		draw_anchor(new_anchor, overlay)
		anchors.append(new_anchor)

func draw_anchor(anchor:Dictionary, overlay:Control) -> void:
	var pos = anchor.position
	overlay.draw_circle(pos, CIRCLE_RADIUS + STROKE_RADIUS, STROKE_COLOR)
	var fill_color:Color = rect_extents.color
	fill_color = fill_color.inverted()
	fill_color.s = 1.0
	fill_color.v = 1.0
	overlay.draw_circle(pos, CIRCLE_RADIUS, fill_color)

func drag_to(event_position : Vector2) -> void:
	if !dragged_anchor:
		return
	
	var viewport_transformation_inv := rect_extents.get_viewport().get_global_canvas_transform().affine_inverse()
	var viewport_position : Vector2 = viewport_transformation_inv.xform(event_position)
	var transform_inv := rect_extents.get_global_transform().affine_inverse()
	var target_position : Vector2 = transform_inv.xform(viewport_position.round())
	var target_size = (target_position - rect_extents.offset).abs() * 2.0
	
	if dragged_anchor.name == ANCHORS.TOP:
		rect_extents.size.y = target_size.y
		return
	elif dragged_anchor.name == ANCHORS.RIGHT:
		rect_extents.size.x = target_size.x
		return
	rect_extents.size = target_size

func forward_canvas_gui_input(event: InputEvent) -> bool:
	if !rect_extents || !rect_extents.is_visible():
		return false
	#print(dragged_anchor)
	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT:
		var mevent : InputEventMouseButton= event as InputEventMouseButton
		#print("foi")
		if !dragged_anchor && mevent.is_pressed():
			#print("foi2")
			for anchor in anchors:
				if !anchor['rect'].has_point(event.position):
					#print("falso")
					continue
				var undo := get_undo_redo()
				undo.create_action("Move anchor")
				undo.add_undo_property(rect_extents, "size", rect_extents.size)
				undo.add_undo_property(rect_extents, "offset", rect_extents.offset)
				dragged_anchor = anchor
				return true
		elif dragged_anchor && !event.is_pressed():
			#print("arrastar")
			drag_to(event.position)
			dragged_anchor = {}
			var undo := get_undo_redo()
			undo.add_do_property(rect_extents, "size", rect_extents.size)
			undo.add_do_property(rect_extents, "offset", rect_extents.offset)
			undo.commit_action()
			return true
	if !dragged_anchor:
		return false
	if event is InputEventMouseMotion:
		var mmevent:InputEventMouseMotion = event
		drag_to(mmevent.position)
		update_overlays()
		return true
	
	if event.is_action_pressed('ui_cancel'):
		dragged_anchor = {}
		var undo = get_undo_redo()
		undo.commit_action()
		undo.undo()
		return true
	
	return false
