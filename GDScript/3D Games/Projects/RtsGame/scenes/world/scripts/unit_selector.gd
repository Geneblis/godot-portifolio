extends Control

var selecting: bool = false
var drag_start: Vector2
var select_box: Rect2

func _input(e: InputEvent) -> void:
	if e is InputEventMouseButton and \
	   e.button_index == MOUSE_BUTTON_LEFT:
		if e.pressed:
			selecting = true
			drag_start = e.position
		else:
			selecting = false
			
			if drag_start.is_equal_approx(e.position):
				select_box = Rect2(e.position, Vector2.ZERO)
			update_selected_units()
			queue_redraw()
	elif selecting and e is InputEventMouseMotion:
		var x_min = min(drag_start.x, e.position.x)
		var y_min = min(drag_start.y, e.position.y)
		select_box = Rect2(x_min, y_min,
			max(drag_start.x, e.position.x) - x_min,
			max(drag_start.y, e.position.y) - y_min)
		update_selected_units()
		queue_redraw()

func _draw() -> void:
	if not selecting: return
	draw_rect(select_box, Color('#00ff0066'))
	draw_rect(select_box, Color('#00ff00'), false, 2.0)

func update_selected_units():
	for unit in get_tree().\
		get_nodes_in_group("selectable-units"):
		if unit.is_in_selection_box(select_box):
			unit.select()
		else:
			unit.deselect()
		
