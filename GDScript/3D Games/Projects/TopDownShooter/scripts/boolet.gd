extends Node3D

const SPEED = 40.0

func _process(delta):
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
func _on_destroy_timer_timeout() -> void:
	queue_free()
