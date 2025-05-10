extends Node2D

const SPEED = 500
var damage: int = randi_range(4, 8)
@onready var bullet_area: Area2D = $BulletArea

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.x * SPEED * delta

func _on_timer_timeout() -> void:
	queue_free()

func _on_bullet_area_body_entered(body: Node2D) -> void:
	#check if it is a body, and if it hasn't taken damage.
	if body.has_node("HealthModule"):
		var HealthModule = body.get_node("HealthModule")
		if body is CharacterBody2D and HealthModule.took_damage == false:
			HealthModule.apply_damage(damage) #body > looks for healthmodule > looks for damage func
			print(damage)
			queue_free()
		else:
			queue_free()
	else:
		queue_free()
	#print("DEBUG: (PROJECTILE) ", self, " Colliding with: ", body)
