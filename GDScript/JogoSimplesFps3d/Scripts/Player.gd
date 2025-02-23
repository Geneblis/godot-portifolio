extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var Sensitivity: float = 0.005
@onready var head: Node3D = $Head
@onready var gpu_particles_3d: GPUParticles3D = $Head/Gun2/GPUParticles3D
@onready var fire_sound: AudioStreamPlayer3D = $Head/Gun2/FireSound
@onready var GunAnim: AnimationPlayer = $Head/Gun2/AnimationPlayer

var GunDelay: float = 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(+event.relative.x * Sensitivity)
		head.rotate_x(-event.relative.y * Sensitivity) 
		head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2)
		

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("Quit"):
		get_tree().quit()

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("D", "A", "S", "W") #alternado para botoes customizados
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	Gun()
	GunDelay -= delta
	move_and_slide()

func Gun():
	if Input.is_action_just_pressed("mouse_1") and GunDelay <= 0:
		GunDelay = 0.1
		GunAnim.stop()
		GunAnim.play("Fire")
		fire_sound.play()
	elif GunAnim.current_animation != "Fire":
		GunAnim.play("idle")
