extends CharacterBody2D
#@onready var health_module: Node = $HealthModule

func _physics_process(delta: float) -> void:
	move_and_slide()
