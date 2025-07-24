extends CanvasLayer

var player: CharacterBody2D
var health_on_hud: int
var ammo_on_hud: int
@onready var update_hud_timer: Timer = $UpdateHudTimer
@onready var hp_text_label: RichTextLabel = $PlayerUI/HpTextLabel
@onready var ammo_text_label: RichTextLabel = $PlayerAmmoUI/AmmoTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = get_tree().get_root().find_child("player", true, false)
	var health_module = player.get_node("healthmodule")
	
	health_on_hud = player.get_node("healthmodule").current_health
	hp_text_label.clear()
	hp_text_label.append_text("HP: " + str(health_on_hud))
	
	# Callable que se refere ao método _on_char_changed_health que 
	# está definido no mesmo script (indicado por self).
	# onde esta o signal?.qual o signal?.connect(função)
	player.update_player_hud.connect(_on_player_shoot)
	health_module.connect("char_changed_health", Callable(self, "_on_char_changed_health")) 

func _on_update_hud_timer_timeout() -> void:
	var player = get_tree().get_root().find_child("player", true, false)
	var health_module = player.get_node("healthmodule")
	
	#update health
	health_on_hud = health_module.current_health
	hp_text_label.clear()
	hp_text_label.append_text("HP: " + str(health_on_hud))
	
	#update ammo
	ammo_on_hud = player.current_aval_ammo
	ammo_text_label.clear()
	ammo_text_label.append_text("AMMO: " + str(ammo_on_hud)+ "/10")

#when player takes damage
func _on_char_changed_health():
	update_hud_timer.start()

func _on_player_shoot():
	update_hud_timer.start()
