extends Area2D
const THANKYOU = preload("res://scenes/ui/tyscene.tscn")
#nao esquecer de colocar canvas layers nos UIs...

func _on_body_entered(body) -> void:
	if body is CharacterBody2D and body.name == "player":
		var thankyou_screen = THANKYOU.instantiate()
		get_tree().get_root().add_child(thankyou_screen)
		
		get_tree().paused = true
		
		await get_tree().create_timer(1.8).timeout
		get_tree().change_scene_to_file("res://scenes/ui/mainmenu.tscn")
		
