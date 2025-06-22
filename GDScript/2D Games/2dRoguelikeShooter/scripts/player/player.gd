extends CharacterBody2D

@export var speed: float = 200.0

#NOTE: Rotate using the sprites as nodes so it can count the offset and rotation as zero.
@onready var gun: Node2D = $Gun
@onready var character_node: Node2D = $CharacterNode 
@onready var camera: Camera2D = $Camera2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $CharacterNode/AnimatedSprite2D

func _ready() -> void:
	gun.connect("FireBullet", camera.start_shake)

func _physics_process(delta: float) -> void:
	_move_player(delta)
	
func _move_player(delta: float) -> void:
	# Monta um vetor 2D de entrada a partir das ações do Input Map
	var input_vec := Vector2(
		Input.get_action_strength("d") - Input.get_action_strength("a"),
		Input.get_action_strength("s")  - Input.get_action_strength("w")
	)
	if input_vec != Vector2.ZERO:
		animated_sprite_2d.play("moving")
		input_vec = input_vec.normalized() * speed
	else:#move this into a new logic.
		animated_sprite_2d.play("idle")
	velocity = input_vec
	
	# Move e desliza (colide) automaticamente
	move_and_slide()
