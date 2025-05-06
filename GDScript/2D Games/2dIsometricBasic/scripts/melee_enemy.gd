extends CharacterBody2D

func _physics_process(delta: float) -> void:
	move_and_slide()

#func _ready() -> void:
#	speed = patrol_speed
#	agent.connect("velocity_computed", move_to_destination)

#func _process(delta: float) -> void:
#	move_enemy(delta)
#	
#func move_enemy(delta : float) -> void:
#	agent.set_target_position(player.global_position)
#	if global_position.distance_to(player.global_position) >= 16:
#		movement_delta = 50 * delta
#	else:
#		movement_delta = 0
#	next_path_position = agent.get_next_path_position()
#	new_velocity = global_position.direction_to(next_path_position) * movement_delta
#	move_to_destination(new_velocity)

#func move_to_destination(new_velocity : Vector2) -> void:
#	global_position = global_position.move_toward(global_position + new_velocity, movement_delta)
