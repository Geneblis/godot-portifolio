extends RigidBody2D

@onready var existance_timer: Timer = $"ExistanceTimer"
@onready var casing: Sprite2D = $Sprite2D
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	existance_timer.start()
	var impulse = Vector2(randi_range(-200, 200), -500)
	apply_impulse(Vector2.ZERO, impulse)
	angular_velocity = randi_range(-10, 10)
	casing.flip_h = impulse.x < 0

func _on_existance_timer_timeout() -> void:
	queue_free()
