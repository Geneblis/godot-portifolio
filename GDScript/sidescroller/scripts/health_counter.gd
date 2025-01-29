extends Control
@onready var label: Label = $Label
var random_directive: int

func _process(delta: float) -> void:
	random_directive = (random_directive - 1)
	label.position.y = random_directive
