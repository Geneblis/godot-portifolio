extends Node3D

@export var stats : Resource
@onready var dup_state : Resource = stats.duplicate()
@onready var anim  = $AnimationPlayer
@onready var shoot = $Shoot
@onready var ray   = $RayCast3D
@onready var nose: Node3D = $RayCast3D/Nose
@onready var weapon: Node3D = $Model/M4A1
@onready var muzzle: GPUParticles3D = $RayCast3D/Nose/GPUParticles3D
var randomMuzzlePos = randf_range(0, 180)
var can_shoot = false

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
		shoot.play()
		can_shoot = false
		
		#disparo
		var b = stats.bullet_scene.instantiate()
		
		#contagem
		dup_state.current_ammo -= 1
		print(dup_state["current_ammo"])
		b.damage = dup_state.damage
		b.global_transform = nose.global_transform
		get_tree().current_scene.add_child(b)
		
		#begin
		if ray.is_colliding():
			var target = ray.get_collider()
			#begin
			if target.is_in_group("enemy"):
				target.hp -= dup_state.damage
				#end
			#end
		#end
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "shoot": #then
		can_shoot = true
		muzzle.rotate_y(randomMuzzlePos)
	elif anim_name == "equip":
		can_shoot = true
	elif anim_name == "unequip":
		can_shoot = false
		visible = false
