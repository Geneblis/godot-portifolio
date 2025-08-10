# ItemData.gd
extends Node
class_name ItemData

@export var icon: AnimatedSprite2D
@export var item_name: String
@export var description: String
@export var weight: float = 1.0
@export var stats: Dictionary = {}

func get_weight() -> float:
	return weight
