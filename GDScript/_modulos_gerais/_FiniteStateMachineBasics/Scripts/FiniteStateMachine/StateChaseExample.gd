##NOTE: This is a basic chase State that uses a navegation/NavMesh agent.
extends State
class_name StateChaseExample

@export var chase_speed : float = 130.0
@export var stop_dist   : float = 16.0
@export var enemy       : CharacterBody2D
@export var agent       : NavigationAgent2D

var player_ref         : CharacterBody2D
var movement_delta     : float
var next_path_position : Vector2

func Enter() -> void:
	print('Entering aggro.')
	player_ref = get_tree().get_first_node_in_group("Player")

func Exit() -> void:
	Transition.emit(self, "Idle") #Leaves current state to idle.

func Physics_Update(delta: float) -> void:
	if not player_ref:
		return

	agent.set_target_position(player_ref.global_position)

	var dist = enemy.global_position.distance_to(player_ref.global_position)
	movement_delta = chase_speed * delta if dist >= stop_dist else 0.0

	next_path_position = agent.get_next_path_position()
	var new_velocity = enemy.global_position.direction_to(next_path_position) * movement_delta

	enemy.global_position = enemy.global_position.move_toward(
		enemy.global_position + new_velocity,
		movement_delta
	)
