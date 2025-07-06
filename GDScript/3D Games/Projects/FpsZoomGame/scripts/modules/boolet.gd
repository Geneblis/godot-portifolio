extends Node3D

@export var speed = 40.0
@export var damage = 0
var direction = Vector3.ZERO

func _physics_process(delta):
	position += transform.basis * Vector3(0, 0, -speed) * delta
	#if direction != Vector3.ZERO:
	#	translate(direction * speed * delta)
		
func _on_body_entered(body):
	if body.is_in_group("enemy"):
		body.hp -= damage
	queue_free()
	
func _on_destroy_timer_timeout() -> void:
	queue_free()
