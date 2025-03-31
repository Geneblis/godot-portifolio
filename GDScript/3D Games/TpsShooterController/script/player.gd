extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var turn_speed : float = 15

@export var camera_target :Node3D
var camera_T  = float()
var strafe = bool(true)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _input(_event):
	if Input.is_action_just_pressed("strafe"):
		strafe = !strafe
		pass


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("right", "left", "backward", "forward")
	var direction = (Vector3(input_dir.x, 0, input_dir.y)).rotated(Vector3.UP, camera_T).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if camera_target:
		camera_T = camera_target.global_transform.basis.get_euler().y
	else:
		return

	#rotate player
	if direction != Vector3.ZERO:
		if strafe:
			rotation.y = lerp_angle(rotation.y, camera_T, delta * turn_speed)
		else:
			rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), turn_speed * delta)

	move_and_slide()
