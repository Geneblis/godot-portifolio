extends Camera2D

const MAX_DIST = 64
const MAX_DIST_EXT = 512

var target_distance = 0
var center_pos = position
var curr_dist = MAX_DIST

func _process(delta: float) -> void:
	var direction = center_pos.direction_to(get_local_mouse_position())
	var target_pos = center_pos + direction * target_distance
	target_pos = target_pos.clamp(center_pos - Vector2(curr_dist, curr_dist), center_pos + Vector2(curr_dist, curr_dist))
	position = target_pos
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		target_distance = center_pos.distance_to(get_local_mouse_position()) / 2
