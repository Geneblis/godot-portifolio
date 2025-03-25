extends CharacterBody3D

# Jump parameters
@export var jump_height: float = 2.25
@export var jump_time_to_peak: float = 0.4
@export var jump_time_to_descent: float = 0.3

@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0 
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0 
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0 

@export var base_speed = 4.5
@export var run_speed = 8.0
@onready var camera: Node3D = $CameraController/Camera3D

var movement_input = Vector2.ZERO

func _movelogic(delta: float) -> void:
	movement_input = Input.get_vector("left", "right", "front", "back").rotated(-camera.global_rotation.y)
	var velocity_2d = Vector2(velocity.x, velocity.z)
	var is_running: bool = Input.is_action_pressed("run")
	
	
	if movement_input != Vector2.ZERO:
		var speed = run_speed if is_running else base_speed
		
		velocity_2d += (movement_input * speed * delta)
		velocity_2d = velocity_2d.limit_length(speed)
		velocity.x = velocity_2d.x
		velocity.z = velocity_2d.y
	else:
		velocity_2d = velocity_2d.move_toward(Vector2.ZERO, base_speed * 4.0 * delta)
		velocity.x = velocity_2d.x
		velocity.z = velocity_2d.y
func _jumplogic(delta: float) -> void:
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = -jump_velocity
	
	var gravity = jump_gravity if velocity.y > 0.0 else fall_gravity
	velocity.y -= gravity * delta

func _physics_process(delta: float) -> void:
	_movelogic(delta)
	_jumplogic(delta)
	move_and_slide()
	
