extends Node3D

@export var min_limit_x: float
@export var max_limit_x: float
@export var horizontal_acceleration: float = 2.0
@export var vertical_acceleration: float = 1.0
@export var edge_scroll_margin: float = 20.0  # Margem para acionar a rolagem nas bordas
@export var mouse_acceleration = 0.005

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_from_vector(event.relative * mouse_acceleration)

func rotate_from_vector(vector: Vector2) -> void:
	if vector.length() == 0:
		return
	rotation.y -= vector.x
	rotation.x -= vector.y
	rotation.x = clamp(rotation.x, min_limit_x, max_limit_x)
