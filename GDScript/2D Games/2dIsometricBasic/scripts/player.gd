extends CharacterBody2D

@export var speed: float = 200.0

##NOTE: Rotate using the sprites as nodes so it can count the offset and rotation as zero.
@onready var gun: Node2D = $Gun
@onready var leg_node: Node2D = $LegNode
@onready var character_node: Node2D = $CharacterNode 
@onready var legs_sprite: AnimatedSprite2D = $LegNode/AnimatedSprite2D

func _physics_process(delta: float) -> void:
	_move_player(delta)
	character_node.look_at(get_global_mouse_position())
	
func _move_player(delta: float) -> void:
	# Monta um vetor 2D de entrada a partir das ações do Input Map
	var input_vec := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up")
	)
	if input_vec != Vector2.ZERO:
		legs_sprite.play("Walking")
		input_vec = input_vec.normalized() * speed
		leg_node.rotation = input_vec.angle()
	else:#move this into a new logic.
		legs_sprite.play("Idle")
	velocity = input_vec
	
	# Move e desliza (colide) automaticamente
	move_and_slide()
