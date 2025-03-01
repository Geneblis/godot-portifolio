extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.01
var gravity = 9.8

@onready var gun: Node3D = $Head/Gun
@onready var head: Node3D = $Head
@onready var gun_anim: AnimationPlayer = $Head/Gun/AnimationPlayer
@onready var camera: Camera3D = $Head/Camera3D

func _ready() -> void:
	#a252de64feca69264e7d8b2b719ea3bd92c5c2624b10ac28b37a5b60e0653c5f
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#player usou algum butao
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("leftwards", "rightwards", "forwards", "backwards")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = 0.0
			velocity.z = 0.0
			
	#NOTE: isso da mais controle ao player enquanto esta no ar
	else:
		velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 2.0)
	
	if Input.is_action_just_pressed("mouse_1"):
		if !gun_anim.is_playing():
			gun_anim.play("Fire")
			
	if Input.is_action_just_pressed("esq"):
		get_tree().quit()
	
	move_and_slide()
