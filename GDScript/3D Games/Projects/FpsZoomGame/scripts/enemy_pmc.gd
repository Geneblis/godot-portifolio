extends CharacterBody3D

@export var Target: Node3D
@onready var model: Node3D = $Assets #rotate this!
@onready var Sight: RayCast3D = $Assets/RayCast3D
@onready var Anims: AnimationPlayer = $Assets/pmc_enemy/AnimationPlayer

var Seeing = false
var TargetDetected = false

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	Sight.look_at(Target.global_position)
	Sight.rotation.y = clamp(Sight.rotation.y, -PI/2,PI/2)
	if Sight.is_colliding():
		if Sight.get_collider() == Target:
			TargetDetected = true
			Seeing = true
		else:
			Seeing = false
	else:
		Seeing = false
	if TargetDetected:
		rotate_y(Sight.rotation.y * delta * 40)
	if TargetDetected:
		if Seeing:
			Anims.play("ShootingLoop")
		else:
			Anims.play("WalkingStandLoop")
	else:
		Anims.play("IdleLoop1")
	move_and_slide()

#func _on_vision_enter(body: Node) -> void:
#	if body.is_in_group("Player"):
#		player_target = body as Node3D
#		look_timer.start()
