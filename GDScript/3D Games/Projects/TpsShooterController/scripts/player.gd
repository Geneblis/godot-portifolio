extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 5.0
var turn_speed: float = 15
var strafe = bool(true)

@export var camera_target: Node3D
var camera_t = float()

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("strafe"):
		strafe = !strafe
		pass

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	#inverted input so we get normalized directions.
	var input_dir = Input.get_vector("right", "left", "backward", "forward")
	var direction = (Vector3(input_dir.x,0,input_dir.y)).rotated(Vector3.UP, camera_t).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(direction.x, 0, SPEED)
		velocity.z = move_toward(direction.z, 0, SPEED)
	
	if camera_target:
		camera_t = camera_target.global_transform.basis.get_euler().y
	else:
		return
		
	#rotate player
	if direction != Vector3.ZERO:
		if strafe: #basic rotation
			rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), turn_speed * delta)
		else: #follows camera
			rotation.y = lerp_angle(rotation.y, camera_t, delta * turn_speed) #follows camera
	
	move_and_slide()
