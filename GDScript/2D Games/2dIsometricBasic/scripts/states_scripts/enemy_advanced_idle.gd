# EnemyAdvancedIdle.gd
extends State
class_name EnemyAdvancedIdle

@export var enemy          : CharacterBody2D
@export var vision_area    : Area2D
@export var next_state     : State
@export var move_speed     : float = 50.0

var move_dir    : Vector2 = Vector2.ZERO
var wander_timer: float  = 0.0

func Enter() -> void:
	_randomize_wander()

func Exit() -> void:
	# para completamente quando sair do idle
	if enemy:
		enemy.velocity = Vector2.ZERO

func Update(delta: float) -> void:
	wander_timer -= delta
	if wander_timer <= 0.0:
		_randomize_wander()

func Physics_Update(delta: float) -> void:
	if not enemy:
		return

	# aplica velocidade de wandering
	enemy.velocity = move_dir * move_speed

	# verifica se o player entrou na vision_area
	for body in vision_area.get_overlapping_bodies():
		if body.is_in_group("Player"):
			emit_signal("Transition", self, next_state.name)
			return

# função auxiliar para escolher nova direção e tempo
func _randomize_wander() -> void:
	move_dir = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	wander_timer = randf_range(1.0, 3.0)
