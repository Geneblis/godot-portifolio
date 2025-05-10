extends Node2D

const BULLET = preload("res://scenes/general_handlers/bullet.tscn")
@onready var marker_2d: Marker2D = $Marker2D
signal FireBullet

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	rotation_degrees = wrap(rotation_degrees, 0, 360)
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -1
	else:
		scale.y = 1
	#bullet instantiaion.
	if Input.is_action_just_pressed("fire"):
		emit_signal("FireBullet")
		var bullet_ins = BULLET.instantiate()
		get_tree().root.add_child(bullet_ins)
		bullet_ins.global_position = marker_2d.global_position
		bullet_ins.rotation = rotation
