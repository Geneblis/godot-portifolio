##NOTE: This is a basic Idle/Wandering state, most common on NPC AI.
extends State
class_name StateIdleExample

#Remember to fill all exports with your nodes.
@export var enemy : CharacterBody2D
@export var move_speed = 50

var move_dir: Vector2
var wander_timer: float

func randomize_wander():
	move_dir = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	wander_timer = randf_range(1,3)
	
func Enter():
	randomize_wander()

func Update(delta: float):
	if wander_timer > 0:
		wander_timer -= delta
	else:
		randomize_wander()
		
func Physics_Update(delta: float):
	if enemy:
		enemy.velocity = move_dir * move_speed
