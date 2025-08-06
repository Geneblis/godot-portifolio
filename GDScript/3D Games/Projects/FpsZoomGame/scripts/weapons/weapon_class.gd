extends Node3D
class_name Weapon3D

@export_category("Bullet Origin")
@export var marker: Node3D
@export_category("Configurações")
@export var stats : Weapon_Base
@onready var dup_state : Resource = stats.duplicate()

@onready var anim = get_node(dup_state.animation_player) as AnimationPlayer
@onready var ray = get_node(dup_state.raycast_node) as RayCast3D
@onready var muzzle = get_node(dup_state.muzzle) as GPUParticles3D
@onready var sound = get_node(dup_state.sound_player) as AudioStreamPlayer3D
##puxa tudo do resource.

var randomMuzzlePos = randf_range(0, 180)

var can_shoot = false

func _ready() -> void:
	sound.stream = dup_state.shoot_sounds
	
	anim.animation_finished.connect(_on_animation_finished)
	
func _process(delta):
	if Input.is_action_pressed("shoot") and can_shoot and not anim.is_playing() and dup_state.current_ammo <= 0:
		if dup_state["reserve_ammo"] >= 0:
			# nao pode ser um valor menor q 0.
			dup_state["reserve_ammo"] = max(dup_state["reserve_ammo"] - dup_state["magazine_size"], 0)
			# nao pode ser um valor maior q a magazine
			dup_state.current_ammo = min(dup_state["reserve_ammo"], dup_state["magazine_size"])
			print("current:")
			print(dup_state["current_ammo"])
			print("stock:")
			print(dup_state["reserve_ammo"])
		else:
			print(dup_state["reserve_ammo"])
		
	if Input.is_action_pressed("shoot") and can_shoot and not anim.is_playing() and dup_state.current_ammo > 0:
		anim.play("shoot")
		sound.play()
		can_shoot = false
		
		#disparo
		if stats.raycast != true:
			var b = stats.bullet_scene.instantiate()
			
			#contagem
			dup_state.current_ammo -= 1
			print(dup_state["current_ammo"])
			b.damage = dup_state.damage
			b.global_transform = marker.global_transform
			get_tree().current_scene.add_child(b)
			
		else:
			if ray.is_colliding() and dup_state.raycast == true:                #se vc quiser usar um sistema de raycasting, caguei pro SOLID.
				var target = ray.get_collider()
				#begin
				if target.is_in_group("enemy"):
					target.hp -= dup_state.damage
					#end
				#end
			#end
			
func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "shoot": #then
		can_shoot = true
		muzzle.rotate_y(randomMuzzlePos)
	elif anim_name == "equip":
		can_shoot = true
	elif anim_name == "unequip":
		can_shoot = false
		visible = false
