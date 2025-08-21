extends Node3D
class_name SelectableUnit

@export var selection_marker: NodePath

var _marker: Node = null
var is_selected: bool = false

func _ready() -> void:
	if selection_marker != NodePath(""):
		if has_node(selection_marker):
			_marker = get_node(selection_marker)
	if _marker:
		_marker.visible = false

func is_in_selection_box(rect: Rect2) -> bool:
	var cam: Camera3D = get_viewport().get_camera_3d()
	if cam == null:
		return false
	if cam.is_position_behind(global_transform.origin):
		return false
	var screen_pos: Vector2 = cam.unproject_position(global_transform.origin)
	return rect.has_point(screen_pos)

func select() -> void:
	if is_selected:
		return
	is_selected = true
	if _marker:
		_marker.visible = true

func deselect() -> void:
	if not is_selected:
		return
	is_selected = false
	if _marker:
		_marker.visible = false
