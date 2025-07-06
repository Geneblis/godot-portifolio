extends CharacterBody3D

@export var Target: Node3D
@onready var model: Node3D = $Assets #rotate this!
@onready var Sight: RayCast3D = $Assets/RayCast3D
@onready var Anims: AnimationPlayer = $Assets/pmc_enemy/AnimationPlayer
@onready var Agent: NavigationAgent3D = $NavigationAgent3D

var Died = false
var Seeing = false
var TargetDetected = false
var Crouching = false

func _ready() -> void:
	Anims.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(animation):
	if animation == "Death2Stand" and Died:
		queue_free()
	if animation == "GoingProne" and not Crouching:
		Crouching = true
	elif animation == "GoingProne" and Crouching:
		Crouching = false

func _physics_process(delta: float) -> void:
	# vision cone
	Sight.look_at(Target.global_position)
	Sight.rotation.y = clamp(Sight.rotation.y, -PI/2,PI/2)
	
	# if enemy has died:
	if Died:
		if Anims.current_animation != "Death2Stand":
			Anims.play("Death2Stand")
			TargetDetected = false
			Crouching = false
		
	# if vision sees player...
	if Sight.is_colliding() and not Died:
		if Sight.get_collider() == Target:
			TargetDetected = true
			Seeing = true
		else:
			Seeing = false
	else:
		Seeing = false
		
	# if player was spotted:
	if TargetDetected and not Died:
		rotate_y(Sight.rotation.y * delta * 40)
		if Seeing and not Crouching:
			Anims.play("GoingProne")
			velocity = Vector3.ZERO
			
		elif not Seeing and Crouching:
			Anims.play_backwards("GoingProne")
			velocity = Vector3.ZERO
			
		elif Seeing and Crouching:
			Anims.play("ShootingLoop")
			velocity = Vector3.ZERO
			
		else:
			Anims.play("WalkingStandLoop")
			Run()
	move_and_slide()

func Run():
	Agent.target_position = Target.global_position
	var CurrentPos = global_position
	var NextPos = Agent.get_next_path_position()
	velocity = Vector3(NextPos - CurrentPos).normalized() * 6
