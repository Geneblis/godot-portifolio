extends Node3D

@onready var chb3d = $".."
@onready var hd = $"."
@onready var inverseKinematicSkeleton: SkeletonIK3D = $"../Rifle Aiming Idle/Skeleton3D/SkeletonIK3D"
var v = Vector3()
var sns = 0.12

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	inverseKinematicSkeleton.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	hd.rotation_degrees.x = v.x
	chb3d.rotation_degrees.y = v.y
	if Input.is_action_just_pressed("Aim"):
		$Camera3D/AnimationPlayer.play("aim")
	if Input.is_action_just_released("Aim"):
		$Camera3D/AnimationPlayer.play_backwards("aim")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		v.y -= (event.relative.x * sns)
		v.x -= (event.relative.y * sns)
		v.x = clamp(v.x, -40, 40)
