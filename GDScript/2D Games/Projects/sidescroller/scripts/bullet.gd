extends Area2D

@export var speed: float = 500
var damage: int = randi_range(4, 8)
var direction: Vector2 = Vector2.ZERO
@onready var bullet_sprite: AnimatedSprite2D = $balaSprite
@onready var bullet_spam_timer: Timer = $BulletSpamTimer
@onready var health: Node2D = $healthmodule

#NOTE: bullet only works with a body that has a health module. 
#Game may crash if no healthmodule is present in body.

func _process(delta):
	position += direction * speed * delta
	if direction.x > 0:
		bullet_sprite.flip_h = false
	else:
		bullet_sprite.flip_h = true

func _on_body_entered(body: Node):
	#check if it is a body, and if it hasn't taken damage.
	if body.has_node("healthmodule"):
		if body is CharacterBody2D and body.health.took_damage == false:
			body.health.apply_damage(damage) #body > looks for healthmodule > looks for damage func
			body.position += Vector2(20 * sign(direction.x), -20)  #joga na direção da bala
			body.velocity.y = -80
			queue_free()
		else:
			queue_free()
	else:
		queue_free()
	#print("DEBUG: (PROJECTILE) ", self, " Colliding with: ", body)

func _on_bullet_spam_timer_timeout() -> void:
	queue_free()
	#print("DEBUG: projectile spend illegal time in space.")
