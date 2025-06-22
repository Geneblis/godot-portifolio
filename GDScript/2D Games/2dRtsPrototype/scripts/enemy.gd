extends CharacterBody2D

enum State { PATROL, CHASE }
var state = State.PATROL

@export var patrol_speed : float = 100.0
@export var chase_speed  : float = 150.0

@onready var agent      : NavigationAgent2D = $NavigationAgent2D
@onready var vision     : Area2D             = $VisionArea
@onready var ray        : RayCast2D          = $VisionRay
@onready var attackArea : Area2D             = $AttackArea

var player_ref : CharacterBody2D

func _ready():
	# detecta entrada e saída da visão
	vision.body_entered.connect(_on_vision_enter)
	vision.body_exited.connect(_on_vision_exit)
	# detecta alcance de ataque
	attackArea.body_entered.connect(_on_attack_enter)

func _physics_process(delta):
	match state:
		State.PATROL:
			_patrol(delta)
		State.CHASE:
			_chase(delta)

func _patrol(delta):
	# exemplo simples: anda devagar para a direita e volta
	velocity.x = patrol_speed
	if position.x > 200:
		patrol_speed = -patrol_speed
	elif position.x < 0:
		patrol_speed = -patrol_speed
	move_and_slide()

func _chase(delta):
	if not player_ref or not is_instance_valid(player_ref):
		state = State.PATROL
		return
	agent.target_position = player_ref.global_position
	if not agent.is_navigation_finished():
		var np = agent.get_next_path_position()
		var dir = (np - global_position).normalized()
		velocity = dir * chase_speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO

func _on_vision_enter(body):
	if body.is_in_group("Player"):
		# verifica linha de visão sem obstáculos
		ray.target_position = body.global_position - ray.global_position
		ray.force_raycast_update()
		if ray.is_colliding() and ray.get_collider() == body:
			player_ref = body
			state = State.CHASE

func _on_vision_exit(body):
	if body == player_ref:
		player_ref = null
		state = State.PATROL

func _on_attack_enter(body):
	if body.is_in_group("Player"):
		print("NPC atacando o player!")
