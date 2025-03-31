extends Node3D

@export var camera_target: Node3D
@export var follow_target: Node3D
@export var follow_target_height_offset = 1.5
@export var pitch_max = 50
@export var pitch_min = -50
var yaw = float()
var pitch = float()
var yaw_sensitivity = .002
var pitch_sensitivity = .002

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	top_level = true

func _input(event):
	if Input.is_action_just_pressed("exit") and event.is_pressed():
		# get_tree().quit()
		if Input.get_mouse_mode() == 0:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if event is InputEventMouseMotion and Input.get_mouse_mode() != 0:
		yaw += -event.relative.x * yaw_sensitivity
		pitch += event.relative.y * pitch_sensitivity

func _physics_process(delta):
	camera_target.rotation.y = lerp(camera_target.rotation.y, yaw, delta * 10)
	camera_target.rotation.x = lerp(camera_target.rotation.x, pitch, delta * 10)

	pitch = clamp(pitch, deg_to_rad(pitch_min), deg_to_rad(pitch_max))

	if follow_target:
		self.global_position = follow_target.global_position + Vector3(0, follow_target_height_offset, 0)
	else: 
		return
