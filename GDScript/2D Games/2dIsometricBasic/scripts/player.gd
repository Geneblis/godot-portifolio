extends CharacterBody2D

@export var speed: float = 50.0
@onready var sprite: Sprite2D = $Sprite2D

func _physics_process(delta: float) -> void:
	_move_player(delta)
	
func _move_player(delta: float) -> void:
	# Monta um vetor 2D de entrada a partir das ações do Input Map
	var input_vec := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up")
	)
	if input_vec != Vector2.ZERO:
		input_vec = input_vec.normalized() * speed
	velocity = input_vec
	
	

	# Move e desliza (colide) automaticamente
	move_and_slide()
