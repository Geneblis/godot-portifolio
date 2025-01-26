extends CharacterBody2D

@export var speed := 200
@onready var snap = get_parent().cell_size

var target := Vector2.ZERO

func _ready():
	target = global_position
	
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		target = event.position 
		print(Vector2(target.x/snap.x, target.y/snap.y), floor(Vector2(target.x/snap.x, target.y/snap.y)))
		target = floor(Vector2(target.x/snap.x, target.y/snap.y))
		target = Vector2(target.x * snap.x, target.y * snap.y)
		
func _physics_process(delta):
	velocity = position.direction_to(target) * speed
	
	if position.distance_to(target) > 2:
		move_and_slide()
