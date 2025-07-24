# NPC.gd
extends CharacterBody2D

enum State { IDLE, PATROL, DETECT, CHASE }
const STATE_NAMES = ["IDLE", "PATROL", "DETECT", "CHASE"]

#region Exported Parameters
@export_group("Temporizadores")
@export var idle_time      : float = 1.0
@export var detect_delay   : float = 0.5

@export_group("Velocidades")
@export var patrol_speed   : float =  80.0
@export var chase_speed    : float = 150.0
#endregion

#region Child Nodes (onready)
@export_group("Nós filhos")
@onready var agent           : NavigationAgent2D = $NavigationAgent2D
@onready var vision_area     : Area2D             = $VisionArea
@onready var vision_ray      : RayCast2D          = $VisionRay
@onready var attack_area     : Area2D             = $AttackArea
@onready var idle_timer      : Timer              = $IdleTimer
@onready var detection_timer : Timer              = $DetectTimer
@onready var chase_timer     : Timer              = $ChaseTimer
#endregion

#region State Variables
var state             : State = State.IDLE
var last_state        : State
var player_ref        : CharacterBody2D
var group_alert_pos   : Vector2
#endregion

#region Lifecycle
func _ready() -> void:
	last_state = state
	vision_area.body_entered.connect(_on_vision_enter)
	vision_area.body_exited .connect(_on_vision_exit)
	attack_area.body_entered.connect(_on_attack_enter)
	idle_timer.timeout.connect(_on_idle_timeout)
	detection_timer.timeout.connect(_on_detect_timeout)
	chase_timer.timeout.connect(_on_chase_timeout)
	_enter_idle()

func _physics_process(delta: float) -> void:
	match state:
		State.IDLE:   _state_idle()
		State.PATROL: _state_patrol(delta)
		State.DETECT: _state_detect(delta)
		State.CHASE:  _state_chase(delta)
	move_and_slide()
	_debug_state_change()
#endregion

#region State Behaviors
func _state_idle() -> void:
	velocity = Vector2.ZERO

#random point
func _state_patrol(delta: float) -> void: #random point
	if not agent.is_navigation_finished():
		var np = agent.get_next_path_position()
		velocity = (np - global_position).normalized() * patrol_speed
	else:
		var angle = randf() * TAU
		var off   = Vector2(cos(angle), sin(angle)) * randf_range(50, 100)
		agent.target_position = global_position + off

func _state_detect(delta: float) -> void: #stops then goes into alert
	# move toward group alert position during group detection phase
	if group_alert_pos:
		agent.target_position = group_alert_pos
		if not agent.is_navigation_finished():
			var np = agent.get_next_path_position()
			velocity = (np - global_position).normalized() * patrol_speed
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO

func _state_chase(delta: float) -> void: # looks for player
	var target_pos: Vector2

	# Target_pos calculation: 
	## means enemy has found player
	if player_ref != null and is_instance_valid(player_ref):
		target_pos = player_ref.global_position
	## means player was spotted
	elif group_alert_pos != null and not agent.is_navigation_finished():
		target_pos = group_alert_pos
	## means player was spotted, enemy's allies has approached the position and found nothing.
	elif $".".position == target_pos and group_alert_pos != null:
		chase_timer.start()
	else:
		_enter_idle()
		return

	# Applies velocity towards target_pos
	agent.target_position = target_pos
	if not agent.is_navigation_finished():
		var np = agent.get_next_path_position()
		velocity = (np - global_position).normalized() * chase_speed
	else:
		velocity = Vector2.ZERO
#endregion

#region Timers
func _enter_idle() -> void:
	state = State.IDLE
	group_alert_pos = Vector2.ZERO
	idle_timer.start()

func _on_idle_timeout() -> void:
	if state == State.IDLE:
		state = State.PATROL

func _on_detect_timeout() -> void:
	if state == State.DETECT:
		state = State.CHASE

# leaves chasing.
func _on_chase_timeout() -> void:
	if state == State.CHASE:
		var bodies = vision_area.get_overlapping_bodies()
		if not bodies.has(player_ref):
			_enter_idle()
#endregion

#region Vision & Group Alert
func _on_vision_enter(body: Node) -> void:
	if state in [State.IDLE, State.PATROL] and body.is_in_group("Player"):
		vision_ray.target_position = body.global_position - vision_ray.global_position
		vision_ray.force_raycast_update()
		if vision_ray.is_colliding() and vision_ray.get_collider() == body:
			player_ref = body
			group_alert_pos = body.global_position
			state = State.DETECT
			detection_timer.start()

			# alerta todo o grupo "Enemy" passando a posição detectada
			get_tree().call_group("Enemy", "_on_group_alert", group_alert_pos)

func _on_group_alert(pos: Vector2) -> void:
	if state in [State.IDLE, State.PATROL]:
		player_ref = null
		group_alert_pos = pos
		state = State.DETECT
		detection_timer.start()

func _on_vision_exit(body: Node) -> void:
	if body == player_ref and state in [State.DETECT, State.CHASE]:
		_enter_idle()
#endregion

#region Attack
func _on_attack_enter(body: Node) -> void:
	if state == State.CHASE and body.is_in_group("Player"):
		print(">> NPC atacando o player!")
#endregion

#region Debug
func _debug_state_change() -> void:
	if last_state != state:
		print(">> NPC State = %s" % STATE_NAMES[state])
		last_state = state
#endregion
