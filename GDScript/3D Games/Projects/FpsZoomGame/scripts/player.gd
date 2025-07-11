extends CharacterBody3D

@onready var head = $HeadNode
@onready var cam  = $HeadNode/Camera3D

const MOUSE_SENSIVITY = 0.2
const GRAVITY = 10
const JUMP_SPEED = 4
const SPEED = 7.0
const ACCEL = 8.0

#starting values
var currentvel = Vector3.ZERO
var velocity_y = 0
var mouse_locked = true
var mouse_input : Vector2
#viewbob
const BOB_FREQ = 1.8
const BOB_AMP = 0.05
var bob_speed = 0.0 

#weaponsway
@export var weapon_holder: Node3D
var def_weapon_holder_pos: Vector3
var weapon_sway_amount: float = 1.25
var weapon_rotation_amount: float = 0.2
var cam_sway_amount: float = 1.0
var cam_rotation_amount: float = 0.175

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	def_weapon_holder_pos = weapon_holder.position
#	end

func _physics_process(delta: float) -> void:
	var dir_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var dir_z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	var input_dir = Vector2(dir_x, dir_z).normalized()
	tilt(input_dir.x, delta)
	
	
	var target_velocity = (global_transform.basis.x * input_dir.x + global_transform.basis.z * input_dir.y) * SPEED
	
	currentvel = currentvel.lerp(target_velocity, ACCEL * delta)
	velocity.x = currentvel.x
	velocity.z = currentvel.z
	
	if Input.is_action_just_pressed("esc"):
		if mouse_locked == true:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouse_locked = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouse_locked = true

	
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity_y = JUMP_SPEED
		else:
			velocity_y = 0
	else:
		velocity_y -= GRAVITY * delta
	
	velocity.y = velocity_y
	move_and_slide()
	
	
	# camera bob
	bob_speed += delta * velocity.length() * float(is_on_floor())
	cam.position = headbob(bob_speed)
	cam.get_child(0).position = headbob(bob_speed)
	sway(delta)
#	end

func _input(event: InputEvent) -> void: #begin
	# checks if mouse is moving
	if event is InputEventMouseMotion: # movimento da camera relativo ao mouse
		head.rotate_x(deg_to_rad(event.relative.y * -MOUSE_SENSIVITY))
		head.rotation_degrees.x = clamp(head.rotation_degrees.x, -90, 60)
		self.rotate_y(deg_to_rad(event.relative.x * -MOUSE_SENSIVITY))
		mouse_input = event.relative
#	end

func headbob(speed): #begin
	var pos = Vector3.ZERO
	pos.y = sin(speed * BOB_FREQ) * BOB_AMP
	pos.x = sin(speed * BOB_FREQ/2) * BOB_AMP
	return pos
#	end

func tilt(inputx, delta):
	if weapon_holder:
		weapon_holder.rotation.z = lerp(weapon_holder.rotation.z, -inputx * weapon_rotation_amount, 10 * delta)
	if cam:
		cam.rotation.z = lerp(head.rotation.z, -inputx * cam_rotation_amount, 10 * delta)

func sway(delta):
	if weapon_holder:
		mouse_input = lerp(mouse_input,Vector2.ZERO,10*delta)
		weapon_holder.rotation.x = lerp(weapon_holder.rotation.x, mouse_input.y * 
		(weapon_rotation_amount/16), 10 * delta)
		weapon_holder.rotation.y = lerp(weapon_holder.rotation.y, mouse_input.x * 
		(weapon_rotation_amount/16), 10 * delta)
