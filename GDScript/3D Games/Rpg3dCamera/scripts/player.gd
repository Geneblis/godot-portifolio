extends CharacterBody3D

const WALKING_SPEED = 3.0
const RUNNING_SPEED = 5.0
const JUMP_VELOCITY = 4.5

var is_running = false
var is_locked = false

@export var speed = 3.0


@onready var visuals: Node3D = $visuals
@onready var anim: AnimationPlayer = $visuals/mixamo_base/AnimationPlayer
@onready var camera_point: Node3D = $camera_point

func _ready():
	GameManager.set_player(self)

#capturar o mouse
func _physics_process(delta: float) -> void:
	
	#is not playing...
	if not anim.is_playing():
		is_locked = false
	
	#chute
	if Input.is_action_just_pressed("kick"):
		if anim.current_animation != "kick":
			anim.play("kick")
			is_locked = true
	
	#corrida
	if Input.is_action_pressed("run"):
		speed = RUNNING_SPEED
		is_running = true
	else:
		speed = WALKING_SPEED
		is_running = false
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#faz o modelo olhar para a posição em que ele esta se movendo para.
	if not is_locked:
		if direction:
			visuals.look_at(position + direction)
			if anim.current_animation != "walking" and not is_running:
				anim.play("walking")
			if anim.current_animation != "running" and is_running:
				anim.play("running")
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			if not is_locked:
				if anim.current_animation != "idle":
					anim.play("idle")
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
			
			#end of else
		move_and_slide()
