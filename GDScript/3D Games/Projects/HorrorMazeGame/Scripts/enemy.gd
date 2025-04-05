extends CharacterBody3D

const SPEED = 2

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

func _physics_process(delta: float) -> void:
	var curr_loc = global_transform.origin
	var desired_loc = nav_agent.get_next_path_position()
	var new_velocity = (desired_loc - curr_loc).normalized() * SPEED

	velocity = velocity.move_toward(new_velocity, .25)
	move_and_slide()

func _update_target_loc(target_loc: Vector3) -> void:
	nav_agent.target_position = target_loc


func _on_target_reached() -> void:
	print("The enemy has catch you!")
	get_tree().quit()
