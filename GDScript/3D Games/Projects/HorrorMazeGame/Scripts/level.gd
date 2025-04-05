extends Node3D

@onready var player: CharacterBody3D = $Player



func _process(delta: float) -> void:
	get_tree().call_group("enemies", "_update_target_loc", player.global_transform.origin)
