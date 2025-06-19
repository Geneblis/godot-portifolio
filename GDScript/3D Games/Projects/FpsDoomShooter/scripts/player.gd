extends CharacterBody3D

@onready var head = $HeadNode
@onready var cam  = $HeadNode/Camera3D

const MOUSE_SENSIVITY = 0.2
const GRAVITY = 10
const JUMP_SPEED = 4
const SPEED = 5.5
const ACCEL = 8.0

#starting values
var currentvel = Vector3.ZERO
var velocity_y = 0

#viewbob
const BOB_FREQ = 1.8
const BOB_AMP = 0.05
var bob_speed = 0.0 

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#	end

func _physics_process(delta: float) -> void:
	var dir_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var dir_z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	var input_dir = Vector2(dir_x, dir_z).normalized()
	
	var target_velocity = (global_transform.basis.x * input_dir.x + global_transform.basis.z * input_dir.y) * SPEED
	
	currentvel = currentvel.lerp(target_velocity, ACCEL * delta)
	velocity.x = currentvel.x
	velocity.z = currentvel.z
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity_y = JUMP_SPEED
		else:
			velocity_y = 0
	else:
		velocity_y -= GRAVITY * delta
	
	velocity.y = velocity_y
	move_and_slide()
	
#	end

func _input(event: InputEvent) -> void: #begin
	# checks if mouse is moving
	if event is InputEventMouseMotion:
		head.rotate_x(deg_to_rad(event.relative.y * -MOUSE_SENSIVITY))
		head.rotation_degrees.x = clamp(head.rotation_degrees.x, -90, 60)
		self.rotate_y(deg_to_rad(event.relative.x * -MOUSE_SENSIVITY))
#	end

func _process(delta: float) -> void: #begin
	bob_speed += delta * velocity.length() * float(is_on_floor())
	cam.position = headbob(bob_speed)
#	end

func headbob(speed): #begin
	var pos = Vector3.ZERO
	pos.y = sin(speed * BOB_FREQ) * BOB_AMP
	pos.x = sin(speed * BOB_FREQ/2) * BOB_AMP
	return pos
#	end
