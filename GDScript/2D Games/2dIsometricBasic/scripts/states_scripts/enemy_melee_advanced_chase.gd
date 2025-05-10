extends State
class_name EnemyAdvancedMeleeChaseState

@export var chase_timer   : float = 5.0
@export var chase_speed   : float = 130.0
@export var stop_dist     : float = 16.0
@export var enemy         : CharacterBody2D
@export var agent         : NavigationAgent2D
@export var vision_area   : Area2D
@export var vision_ray    : RayCast2D
@export var idle_state_name : State

var player_ref           : CharacterBody2D
var chase_time_left      : float

func Enter() -> void:
	player_ref = get_tree().get_first_node_in_group("Player") as CharacterBody2D
	chase_time_left = chase_timer

func Exit() -> void:
	player_ref = null

func Physics_Update(delta: float) -> void:
	if not player_ref:
		return

	# se o player está dentro do cone (Area2D), reseta o timer
	if vision_area.get_overlapping_bodies().has(player_ref):
		chase_time_left = chase_timer

	# se ainda há tempo de chase, continua perseguindo
	if chase_time_left > 0.0:
		_do_chase(delta)
		chase_time_left -= delta
		return

	# tempo esgotou – verifica raycast de visão
	vision_ray.target_position = player_ref.global_position - vision_ray.global_position
	vision_ray.force_raycast_update()
	if not vision_ray.is_colliding() or vision_ray.get_collider() != player_ref:
		# perdeu o player – volta ao Idle
		emit_signal("Transition", self, idle_state_name.name)

func _do_chase(delta: float) -> void:
	agent.set_target_position(player_ref.global_position)
	var dist = enemy.global_position.distance_to(player_ref.global_position)
	var movement_delta = chase_speed * delta if dist >= stop_dist else 0.0
	var next_pos = agent.get_next_path_position()
	var dir = enemy.global_position.direction_to(next_pos)
	enemy.global_position = enemy.global_position.move_toward(
		enemy.global_position + dir * movement_delta,
		movement_delta
	)
