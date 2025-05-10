extends Camera2D

const MAX_DIST = 64
const MAX_DIST_EXT = 512
var shake_duration := 0.3
var shake_intensity := 2.0
var shake_timer := 0.0
var rng = RandomNumberGenerator.new()

var target_distance = 0
var center_pos = position
var curr_dist = MAX_DIST

func _ready() -> void:
	rng.randomize()

func start_shake() -> void:
	shake_timer = shake_duration

func _process(delta: float) -> void:
	var direction = center_pos.direction_to(get_local_mouse_position())
	var target_pos = center_pos + direction * target_distance
	target_pos = target_pos.clamp(center_pos - Vector2(curr_dist, curr_dist), center_pos + Vector2(curr_dist, curr_dist))
	position = target_pos
	
	if shake_timer > 0:
		shake_timer -= delta
		offset = Vector2(
			rng.randf_range(-shake_intensity, shake_intensity),
			rng.randf_range(-shake_intensity, shake_intensity)
		)
	else:
		offset = Vector2.ZERO
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		target_distance = center_pos.distance_to(get_local_mouse_position()) / 2
