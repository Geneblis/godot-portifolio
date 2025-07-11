extends Camera3D

##Mover isso pro handler das armas como funcao... Tudo isso.

# Camera shake on continuous shooting:
# - While “shoot” is held, triggers repeated shake bursts.
# - Odd-numbered bursts tilt up; even-numbered bursts tilt down.
# - Shake intensity decays over each burst.

@export var max_shake_degrees: float    = 0.7   # starting shake amplitude (degrees)
@export var burst_duration: float       = 0.05    # seconds per shake burst

var _base_rotation: Vector3
var _remaining_shake_time: float = 0.0
var _next_shake_direction: int = 1  # 1 = up, -1 = down

func _ready() -> void:
	_base_rotation = rotation_degrees

func _process(delta: float) -> void:
	# start a new burst whenever shooting and no burst is active
	if Input.is_action_pressed("shoot") and _remaining_shake_time <= 0.0:
		_remaining_shake_time = burst_duration
		_next_shake_direction *= -1  # toggle direction each burst

	if _remaining_shake_time > 0.0:
		# how far we are into the burst (1 → 0)
		var burst_progress := _remaining_shake_time / burst_duration
		# current shake amplitude decays over time
		var current_amplitude := max_shake_degrees * burst_progress
		# vertical offset only, in the chosen direction
		var vertical_offset := randf_range(0.0, current_amplitude) * _next_shake_direction
		rotation_degrees.x = _base_rotation.x + vertical_offset
		rotation_degrees.y = _base_rotation.y + vertical_offset
		# decrement timer
		_remaining_shake_time = max(_remaining_shake_time - delta, 0.0)
		# end of burst: restore exactly to base rotation
		if _remaining_shake_time == 0.0:
			rotation_degrees = _base_rotation
	else:
		rotation_degrees = _base_rotation
