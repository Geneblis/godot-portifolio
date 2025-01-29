extends Node

var took_damage: bool = false 
signal char_died
signal char_changed_health
var current_health: int
@export var max_health: int = 100
@onready var damage_timer: Timer = $DamageTimer
@onready var blood_particles: CPUParticles2D = $BloodParticles
const DAMAGE_COUNTER = preload("res://scenes/ui/damage_counter.tscn")
const HEALTH_COUNTER = preload("res://scenes/ui/health_counter.tscn")

func _ready():
	current_health = max_health  #sets the entity curr health to its max
	
func apply_damage(amount: int) -> void:
	if took_damage == true: #avoids damage while invencible
		return
		
	if took_damage == false:
		char_changed_health.emit()
		damage_timer.start() #timer for invencibility
		current_health = clamp(current_health - amount, 0, max_health)
		#print("DEBUG: (DAMAGE) Current health of target: ", current_health )
		
		#function for flash anim
		flash_red()
		
		#health popup
		var health_show = HEALTH_COUNTER.instantiate()
		self.get_parent().add_child(health_show)
		health_show.label.text = str(current_health)
		
		#damage popupp
		var damage_show = DAMAGE_COUNTER.instantiate()
		self.get_parent().add_child(damage_show)
		damage_show.label.text = ("-" + str(amount))
		
		#plays blood particles if it is a humanoid
		if self.get_parent() is CharacterBody2D:
			blood_particles.emitting = true
		if current_health == 0:
			_on_died()
		
#healing code
func apply_heal(amount: int) -> void:
	current_health = clamp(current_health + amount, 0, max_health)
	#print("DEBUG: (HEAL) Current health of target: ", current_health)
	
func _on_died(): #chama um signal
	char_died.emit()
	
func flash_red(): #sets damage colour 
	took_damage = true
	self.get_parent().sprite.modulate = Color(1.25, 0.5, 0.5, 0.76)
	
func reset_sprite(): #returns to normal
	self.get_parent().sprite.modulate = Color(1,1,1)
	
func _on_damage_timer_timeout(): #invencibilitity is over
	took_damage = false
	blood_particles.emitting = false
	reset_sprite()
