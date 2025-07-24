# PlayerMouseNavController.gd
extends CharacterBody2D
class_name PlayerMouseNavController
@export_category("Configuration and Nodes")
@export var speed : float = 400.0
@export var nav_agent : NavigationAgent2D
@export var body_node : CharacterBody2D

var _marker_instance : Marker2D = null

func _clearMarkers() -> void:
	if _marker_instance:
		_marker_instance.queue_free()
		_marker_instance = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		var dst = get_global_mouse_position()
		_set_destination(dst)

func _physics_process(delta: float) -> void:
	if nav_agent.is_navigation_finished():
		_stop()
	else:
		_move_along_path(delta)

func _set_destination(dst: Vector2) -> void:
	# limpa antigo
	_clearMarkers()

	# instancia um Marker2D simples
	_marker_instance = Marker2D.new()
	get_tree().current_scene.add_child(_marker_instance)
	_marker_instance.global_position = dst

	nav_agent.target_position = dst

func _move_along_path(delta: float) -> void:
	var next_pos = nav_agent.get_next_path_position()
	var dir = (next_pos - global_position).normalized()
	velocity = dir * speed
	
	#Animations
	#if dir.length() > 0.1:
	#	legs_sprite.play("Walking")
	#	leg_node.rotation = dir.angle()
	#else:
	#	legs_sprite.play("Idle")
	
	body_node.look_at(get_global_mouse_position())
	move_and_slide()
func _stop() -> void:
	velocity = Vector2.ZERO
	#legs_sprite.play("Idle")
	_clearMarkers()
