extends Node3D

@export var speed = 80.0
@export var damage = 0
var direction = Vector3.ZERO
@onready var collArea: Area3D = $Area3D
@onready var blood: GPUParticles3D = $GPUParticles3D
@onready var mesh: CSGBox3D = $CSGBox3D

func _ready() -> void:
	collArea.body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += transform.basis * Vector3(0, 0, -speed) * delta
	
func _on_body_entered(body):
	if body.is_in_group("Enemy"):
		body.health_node.apply_damage(damage)
		print("Vida do alvo: " + str(body.health_node.current_health))
		blood.emitting = true
		speed = 0
		mesh.queue_free()
		await get_tree().create_timer(1.0).timeout
		queue_free()
	
func _on_destroy_timer_timeout() -> void:
	queue_free()
