extends CharacterBody2D
@onready var health_module: Node = $HealthModule

func _ready() -> void:
	health_module.connect("char_changed_health", self._on_char_changed_health)
func _on_char_changed_health() -> void:
	print("oi")

func _physics_process(delta: float) -> void:
	move_and_slide()
