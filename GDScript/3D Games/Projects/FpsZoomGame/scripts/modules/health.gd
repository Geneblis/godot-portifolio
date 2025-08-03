extends Node

signal char_died
signal char_changed_health

@export var max_health: int = 100
@export var invincibility_time: float = 1.0  # duração da invencibilidade em segundos

var current_health: int
var is_invincible: bool = false

func _ready():
	current_health = max_health

func apply_damage(amount: int) -> void:
	if is_invincible and not current_health <= 0:
		return

	# aplica dano
	current_health = clamp(current_health - amount, 0, max_health)
	emit_signal("char_changed_health")

	# dispara flash e invencibilidade
	await _start_invincibility()
	
	if current_health <= 0:
		emit_signal("char_died")

func apply_heal(amount: int) -> void:
	current_health = clamp(current_health + amount, 0, max_health)
	emit_signal("char_changed_health")

func _start_invincibility() -> void:
	is_invincible = true
	#instanciamento do timer
	var timer = Timer.new()
	timer.wait_time = invincibility_time
	timer.one_shot = true
	add_child(timer)
	timer.start()
	await timer.timeout
	timer.queue_free()
	is_invincible = false
