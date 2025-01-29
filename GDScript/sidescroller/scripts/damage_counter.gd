extends Control
@onready var label: Label = $Label
var random_directive_damage: float

func _process(delta: float) -> void:
	random_directive_damage = (random_directive_damage + -0.5)
	label.position.y = random_directive_damage
