extends CharacterBody2D


var canmove: bool = true
const SPEED = 150.0
const JUMP_VELOCITY = -300.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var movement_timer: Timer = $MovementTimer

func _on_movement_timer_timeout() -> void:
	canmove = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta;

	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY;

	var direction := Input.get_axis("ui_left", "ui_right")
	
	#direita
	if direction > 0 && canmove == true:
		movement_timer.start()
		canmove = false
		sprite.flip_h = false
		position.x = position.x + 16
		#esquerda
	elif direction < 0 && canmove == true:
		movement_timer.start()
		canmove = false
		position.x = position.x + -16
		sprite.flip_h = true
		
	#animations
	
	if is_on_floor():
		if direction == 0:
			sprite.play("idle")
		else: 
			sprite.play("run")
	else:
		sprite.play("jump")


	#if direction:
		#velocity.x = direction * SPEED;
	#else:
	#	velocity.x = move_toward(velocity.x, 0, SPEED);

	move_and_slide();
