extends Node2D

const SPEED = 150


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.x * SPEED * delta


func _on_timer_timeout() -> void:
	queue_free()
