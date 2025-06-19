extends Node3D

@export var damage = 1.0

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var shoot: AudioStreamPlayer = $Shoot
@onready var ray: RayCast3D = $RayCast3D

var can_shoot = false

func _process(delta: float) -> void:
	if Input.is_action_pressed("shoot") and can_shoot and not anim.is_playing():
		anim.play("shoot")
		shoot.play()
		can_shoot = false
		if ray.is_colliding():
			if ray.get_collider().is_in_group("enemy"):
				ray.get_collider().hp -= damage

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "shoot": #then
		can_shoot = true
	elif anim_name == "equip":
		can_shoot = true
	elif anim_name == "unequip":
		can_shoot = false
		visible = false
