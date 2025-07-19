extends Node3D
class_name Weapon3D

@export_category("Configurações")
@export var damage: float
@export var bullet_speed: float
@export var raycast: bool

@export_category("Visuais")
@export var weapon_nose: Node3D
@export var ray: RayCast3D
@export var shoot: AudioStreamPlayer
@export var anim: AnimationPlayer
@export var muzzle: GPUParticles3D

const BULLET = preload("uid://c6305vhfdj22n")

var can_shoot = false

func _ready() -> void:
	anim.animation_finished.connect(_on_animation_finished)

func _process(delta):
	if Input.is_action_pressed("shoot") and can_shoot and not anim.is_playing():
		anim.play("shoot")
		shoot.play()
		can_shoot = false
		
		#disparo
		if raycast != true:
			var b = BULLET.instantiate()
			b.damage = damage
			b.global_transform = weapon_nose.global_transform
			get_tree().current_scene.add_child(b)
		else:
			if ray.is_colliding() and raycast == true:                #se vc quiser usar um sistema de raycasting, caguei pro SOLID.
				var target = ray.get_collider()
				#begin
				if target.is_in_group("enemy"):
					target.hp -= damage
					#end
				#end
			#end
			
func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "shoot": #then
		can_shoot = true
	elif anim_name == "equip":
		can_shoot = true
	elif anim_name == "unequip":
		can_shoot = false
		visible = false
