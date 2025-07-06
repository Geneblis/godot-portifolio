extends CharacterBody3D

@export var turn_speed       : float = 5.0    # radians per second
@export var chase_speed      : float = 5.0    # movement speed when chasing

@onready var nav_agent       : NavigationAgent3D = $NavigationAgent3D
@onready var look_timer      : Timer             = $LookTimer
@onready var vision_area     : Area3D            = $BodyNode/Area3D

var player_target  : Node3D  = null             # reference to player when detected
var is_chasing     : bool    = false            # chasing state
@onready var animation_player: AnimationPlayer = $BodyNode/simple_pmc/AnimationPlayer

func _ready() -> void:
	vision_area.body_entered.connect(_on_vision_enter)
	look_timer.timeout.connect(_on_look_timer_timeout)

func _physics_process(delta: float) -> void:
	if is_chasing and player_target:
		animation_player.play("walk")
		nav_agent.target_position = player_target.global_position
		var next_point = nav_agent.get_next_path_position()
		#region Point Proximity
		if next_point.distance_to(global_position) > 0.1:
			velocity = (next_point - global_position).normalized() * chase_speed
			var direction_to_player = player_target.global_position - global_position
			direction_to_player.y = 0
			direction_to_player = direction_to_player.normalized()
			
			var current_forward = -global_transform.basis.z
			current_forward.y = 0
			current_forward = current_forward.normalized()
			
			var turn_angle = atan2(current_forward.cross(direction_to_player).y, 
			current_forward.dot(direction_to_player) )
			rotate_y(clamp(turn_angle, -turn_speed * delta, turn_speed * delta))
		else:
			velocity = Vector3.ZERO
		#endregion
	else:
		velocity = Vector3.ZERO

	move_and_slide()

func _on_vision_enter(body: Node) -> void:
	if body.is_in_group("Player"):
		player_target = body as Node3D
		look_timer.start()

func _on_look_timer_timeout() -> void:
	if player_target and vision_area.get_overlapping_bodies().has(player_target):
		is_chasing = true
