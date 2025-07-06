extends Node3D

@export var damage = 1.0
@export var bullet_speed = 50.0  # ajuste à vontade

@onready var anim  = $AnimationPlayer
@onready var shoot = $Shoot
@onready var ray   = $RayCast3D
@onready var nose: Node3D = $RayCast3D/Nose
@onready var weapon: Node3D = $Model/M4A1
@onready var muzzle: GPUParticles3D = $RayCast3D/Nose/GPUParticles3D
var randomMuzzlePos = randf_range(0, 180)

const BULLET = preload("res://scenes/boolet.tscn")

var can_shoot = false

func _process(delta):
	if Input.is_action_pressed("shoot") and can_shoot and not anim.is_playing():
		anim.play("shoot")
		shoot.play()
		can_shoot = false
		
		#disparo
		var b = BULLET.instantiate()
		
		b.damage = damage
		b.global_transform = nose.global_transform
		get_tree().current_scene.add_child(b)
		
		#begin
		if ray.is_colliding():
			var target = ray.get_collider()
			#begin
			if target.is_in_group("enemy"):
				target.hp -= damage
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
