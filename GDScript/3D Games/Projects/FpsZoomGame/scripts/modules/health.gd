extends Node

var took_damage: bool = false 
signal char_died
signal char_changed_health
var current_health: int
@export var max_health: int = 100
@onready var damage_timer: Timer = $DamageTimer

@onready var area_3d: Area3D = $BodyNode/Area3D

func _ready():
	current_health = max_health  #sets the entity curr health to its max
	
func apply_damage(amount: int) -> void:
	if took_damage == true: #avoids damage while invencible
		return
		
	if took_damage == false:
		emit_signal("char_changed_health")
		damage_timer.start() #timer for invencibility
		current_health = clamp(current_health - amount, 0, max_health)
		#print("DEBUG: (DAMAGE) Current health of target: ", current_health )
		
		#function for flash anim
		flash_red()
		
		if current_health == 0:
			_on_died()
		
#healing code
func apply_heal(amount: int) -> void:
	current_health = clamp(current_health + amount, 0, max_health)
	#print("DEBUG: (HEAL) Current health of target: ", current_health)
	
func _on_died(): #chama um signal
	emit_signal("char_died")
	
func flash_red(): #sets damage colour 
	took_damage = true
	
func reset_sprite(): #returns to normal
	pass
	
func _on_damage_timer_timeout(): #invencibilitity is over
	took_damage = false
	reset_sprite()
