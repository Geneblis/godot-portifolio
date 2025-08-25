extends Node3D

@export var Weapon: PackedScene
@export var CollisionArea: Area3D
@export var WeaponLabel: Label3D

func _ready() -> void:
	WeaponLabel.text = Weapon.instantiate().name
	CollisionArea.body_entered.connect(_player_is_in_area)

func _player_is_in_area(body: Node3D) -> void: 
	print(body.to_string())
