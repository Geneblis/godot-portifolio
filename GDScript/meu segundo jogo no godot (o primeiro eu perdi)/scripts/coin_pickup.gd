extends Area2D
@onready var gm: Node = %Gamemanager
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body):
	print("Corpo entrou na área de moeda: ", body.name)
	gm.add_point();
	animation_player.play("new_animation");
