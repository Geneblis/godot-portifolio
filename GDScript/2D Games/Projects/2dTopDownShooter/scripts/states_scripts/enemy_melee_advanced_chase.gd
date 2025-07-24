extends State
class_name EnemyAdvancedMeleeChaseState

@export_category("State: Configuration")
@export var chase_timer       : float       = 5.0
@export var chase_speed       : float       = 130.0
@export var stop_dist         : float       = 16.0
@export var wait_time         : float       = 2.0  # tempo de espera na última posição
@export_category("State: Nodes")
@export var enemy             : CharacterBody2D
@export var agent             : NavigationAgent2D
@export var vision_area       : Area2D
@export var vision_ray        : RayCast2D
@export var idle_state        : State        # o nó State de Idle

var player_ref        : CharacterBody2D
var chase_time_left   : float
var last_known_pos    : Vector2
var searching         : bool    = false
var wait_timer        : float   = 0.0
var marker_instance   : Marker2D

func Enter() -> void:
	player_ref      = get_tree().get_first_node_in_group("Player") as CharacterBody2D
	chase_time_left = chase_timer
	searching       = false
	wait_timer      = 0.0
func Exit() -> void:
	player_ref = null
func Physics_Update(delta: float) -> void:
	if not player_ref:
		return

	# 1) checa área + visão
	var in_area = vision_area.get_overlapping_bodies().has(player_ref)
	var has_los = false
	if in_area:
		vision_ray.target_position = player_ref.global_position - vision_ray.global_position
		vision_ray.force_raycast_update()
		has_los = vision_ray.is_colliding() and vision_ray.get_collider() == player_ref

	if has_los:
		# reinicia chase e guarda posição
		chase_time_left = chase_timer
		last_known_pos  = player_ref.global_position
		searching       = false
	else:
		# assim que perder visão, marca e vai para lá
		if not searching:
			searching = true
			wait_timer = wait_time   # começa o timer quando chega
			agent.target_position = last_known_pos

	# 2) decrementa o chase timer sempre que estiver em chase
	chase_time_left -= delta

	# 3) se ainda há visão e tempo, persegue diretamente
	if chase_time_left > 0.0 and has_los:
		_do_chase(player_ref.global_position, delta)
		return

	# 4) se está buscando (sem visão mas ainda com marker), move até lá e depois espera
	if searching:
		_move_toward_last_known(delta)
		return

	# 5) chegou o tempo de chase E já buscou → volta ao Idle
	if chase_time_left <= 0.0:
		emit_signal("Transition", self, idle_state.name)


func _do_chase(target: Vector2, delta: float) -> void:
	agent.target_position = target
	_move_along_agent(delta)

func _move_along_agent(delta: float) -> void:
	var dist = enemy.global_position.distance_to(agent.target_position)
	var movement_delta = chase_speed * delta if dist >= stop_dist else 0.0
	var next_pos = agent.get_next_path_position()
	var dir = enemy.global_position.direction_to(next_pos)
	enemy.global_position = enemy.global_position.move_toward(
		enemy.global_position + dir * movement_delta,
		movement_delta
	)
func _move_toward_last_known(delta: float) -> void:
	var dist = enemy.global_position.distance_to(last_known_pos)
	if dist > stop_dist:
		agent.target_position = last_known_pos
		_move_along_agent(delta)
	else:
		wait_timer -= delta
		if wait_timer <= 0.0:
			emit_signal("Transition", self, idle_state.name)
