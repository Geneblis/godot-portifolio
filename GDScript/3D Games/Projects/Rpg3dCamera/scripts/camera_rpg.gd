extends Node3D

@onready var background_vp: SubViewport = $base_camera/background_vp_container/background_vp
@onready var foreground_vp: SubViewport = $base_camera/foreground_vp_container2/foreground_vp

@onready var background_camera: Camera3D = $base_camera/background_vp_container/background_vp/background_camera
@onready var foreground_camera: Camera3D = $base_camera/foreground_vp_container2/foreground_vp/foreground_camera

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_resize()

func _resize():
	background_vp.size = DisplayServer.window_get_size()
	foreground_vp.size = DisplayServer.window_get_size()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	background_camera.global_transform = GameManager.player.camera_point.global_transform
	foreground_camera.global_transform = GameManager.player.camera_point.global_transform
