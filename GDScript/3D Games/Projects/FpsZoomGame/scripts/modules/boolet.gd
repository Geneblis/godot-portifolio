extends Node3D

@export var speed = 40.0
@export var damage = 0
var direction = Vector3.ZERO
@onready var collArea: Area3D = $Area3D

func _ready() -> void:
	collArea.body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += transform.basis * Vector3(0, 0, -speed) * delta
	#if direction != Vector3.ZERO:
	#	translate(direction * speed * delta)
		
func _on_body_entered(body):
	if body.is_in_group("enemy"):
		body.hp -= damage
		
	# placeholder
	if body.is_in_group("Enemy"):
		body.Died = true
	queue_free()
	
func _on_destroy_timer_timeout() -> void:
	queue_free()
