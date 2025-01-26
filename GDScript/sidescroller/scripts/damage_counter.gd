extends Control
@onready var label: Label = $Label


func _ready() -> void:	
	var random_directive_1 = randi_range(5, -5)
	label.position.x = random_directive_1
	
	var random_directive_2 = randi_range(5, -5)
	label.position.y = random_directive_2

#cool shit
#func _process(delta: float) -> void:
#	var random_directive_1 = randi_range(10, -10)
#	label.position.x = random_directive_1
#	
#	var random_directive_2 = randi_range(10, -10)
#	label.position.y = random_directive_2
