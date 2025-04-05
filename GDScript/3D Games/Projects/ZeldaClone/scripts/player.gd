extends CharacterBody3D

# Jump parameters
@export var jump_height: float = 2.25
@export var jump_time_to_peak: float = 0.4
@export var jump_time_to_descent: float = 0.3
@onready var playermodel: Node3D = $GodetteSkin

@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0 
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0 
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0 

@onready var speed_modifier = 1.0
@onready var defend_speed = 3.0
@export var base_speed = 4.5
@export var run_speed = 8.0
@onready var camera: Node3D = $CameraController/Camera3D

var defend:bool = false:
	set(val):
		if not defend and val:
			playermodel._defend(true)
		if defend and not val:
			playermodel._defend(false)
		defend = val

var weapon_active:= true

var movement_input = Vector2.ZERO

func _movelogic(delta: float) -> void:
	movement_input = Input.get_vector("left", "right", "front", "back").rotated(-camera.global_rotation.y)
	var velocity_2d = Vector2(velocity.x, velocity.z)
	var is_running: bool = Input.is_action_pressed("run")
	
	
	if movement_input != Vector2.ZERO:
		var speed = run_speed if is_running else base_speed
		speed = defend_speed if defend else speed
		
		velocity_2d += (movement_input * speed * delta * 8.0)
		velocity_2d = velocity_2d.limit_length(speed) * speed_modifier
		velocity.x = velocity_2d.x
		velocity.z = velocity_2d.y
		playermodel._set_move_state("Running_A")
		
		#where is the character looking?
		var target_angle = -movement_input.angle() + PI/2
		playermodel.rotation.y = move_toward(playermodel.rotation.y, target_angle, 6.0 * delta)
		
	else:
		velocity_2d = velocity_2d.move_toward(Vector2.ZERO, base_speed * 4.0 * delta)
		velocity.x = velocity_2d.x
		velocity.z = velocity_2d.y
		playermodel._set_move_state("Idle")
		
func _jumplogic(delta: float) -> void:
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = -jump_velocity
	else:
		playermodel._set_move_state("Jump_Idle")
	
	var gravity = jump_gravity if velocity.y > 0.0 else fall_gravity
	velocity.y -= gravity * delta

func _abilities_logic() -> void:
	if Input.is_action_just_pressed("ability"):
		if weapon_active:
			playermodel._attack()
			stop_movement(0.2, 0.2)
		else:
			playermodel.cast_spell()
			stop_movement(0.3, 0.8)
	
	defend = Input.is_action_pressed("block")

	if Input.is_action_just_pressed("switched") and not playermodel.attacking:
		weapon_active = not weapon_active
		playermodel.switch_weapon(weapon_active)

func stop_movement(start_duration: float, end_duration: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "speed_modifier", 0.0, start_duration)
	tween.tween_property(self, "speed_modifier", 1.0, end_duration)

func _hit():
	playermodel.hit()
	stop_movement(0.3, 0.45)

func _physics_process(delta: float) -> void:
	_movelogic(delta)
	_abilities_logic()
	_jumplogic(delta)
	if Input.is_action_just_pressed("ui_text_backspace"):
		_hit()
	move_and_slide()
