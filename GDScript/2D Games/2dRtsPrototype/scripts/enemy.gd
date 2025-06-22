# NPC.gd
extends CharacterBody2D

enum State { IDLE, PATROL, DETECT, CHASE }

@export var idle_time     : float = 1.0
@export var patrol_speed : float = 80.0
@export var chase_speed  : float = 150.0
@export var detect_delay : float = 0.5

@onready var agent       : NavigationAgent2D = $NavigationAgent2D
@onready var vision      : Area2D             = $VisionArea
@onready var ray         : RayCast2D          = $VisionRay
@onready var attack_area : Area2D             = $AttackArea
@onready var detection_timer    : Timer              = $DetectTimer
@onready var idle_timer      : Timer              = $IdleTimer

var state      : State = State.IDLE
var last_state : State
var player_ref : CharacterBody2D

func _ready() -> void:
	last_state = state
	
	vision.body_entered.connect(_on_vision_enter)
	vision.body_exited .connect(_on_vision_exit)
	attack_area.body_entered.connect(_on_attack_enter)

	detection_timer.timeout.connect(_on_DetectTimer_timeout)
	idle_timer.timeout.connect(_on_IdleTimer_timeout)

	_enter_idle()

func _physics_process(delta: float) -> void:
	match state:
		State.IDLE:
			velocity = Vector2.ZERO
		State.PATROL:
			_do_patrol(delta)
		State.DETECT:
			velocity = Vector2.ZERO
		State.CHASE:
			_do_chase(delta)
	move_and_slide()
	_check_state_debug()

func _check_state_debug():
	if last_state != state:
		match state:
			State.IDLE:
				print(">> NPC State = IDLE")
			State.PATROL:
				print(">> NPC State = PATROL")
			State.DETECT:
				print(">> NPC State = DETECT")
			State.CHASE:
				print(">> NPC State = CHASE")
		last_state = state

func _enter_idle() -> void:
	state = State.IDLE
	idle_timer.start()

func _on_IdleTimer_timeout() -> void:
	if state == State.IDLE:
		state = State.PATROL

func _do_patrol(delta: float) -> void:
	if not agent.is_navigation_finished():
		var np  = agent.get_next_path_position()
		var dir = (np - global_position).normalized()
		velocity = dir * patrol_speed
	else:
		var angle = randf() * TAU
		var off = Vector2(cos(angle), sin(angle)) * randf_range(50, 100)
		agent.target_position = global_position + off

func _on_vision_enter(body):
	if body.is_in_group("Player") and state in [State.IDLE, State.PATROL]:
		ray.target_position = body.global_position - ray.global_position
		ray.force_raycast_update()
		if ray.is_colliding() and ray.get_collider() == body:
			player_ref = body
			state = State.DETECT
			detection_timer.start()

func _on_DetectTimer_timeout() -> void:
	if player_ref and state == State.DETECT:
		state = State.CHASE

func _do_chase(delta: float) -> void:
	if not player_ref or not is_instance_valid(player_ref):
		_enter_idle()
		return
	agent.target_position = player_ref.global_position
	if not agent.is_navigation_finished():
		var np  = agent.get_next_path_position()
		var dir = (np - global_position).normalized()
		velocity = dir * chase_speed
	else:
		velocity = Vector2.ZERO

func _on_vision_exit(body):
	if body == player_ref and state in [State.DETECT, State.CHASE]:
		player_ref = null
		print(">> NPC lost sight, back to IDLE")
		_enter_idle()

func _on_attack_enter(body):
	#if body.is_in_group("Player") and state == State.CHASE:
	#	print(">> NPC atacando o player!")
	if body.is_in_group("Player") and player_ref != null:
		print(">> NPC atacando o player!")
