extends CharacterBody2D
@onready var health_module: Node = $HealthModule
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	health_module.connect("char_changed_health", self._on_char_changed_health)
	
func _on_char_changed_health() -> void:
	if health_module.current_health <= 0:
		queue_free()

func _physics_process(delta: float) -> void:
	move_and_slide()
	if velocity != Vector2.ZERO:
		animated_sprite_2d.play("moving")
	else:
		animated_sprite_2d.play("idle")
