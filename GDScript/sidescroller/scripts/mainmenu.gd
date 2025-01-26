extends CanvasLayer
const _1_ST_PLAYABLEWORLD = preload("res://scenes/levels/1st_playableworld.tscn")
const SETTINGS_MENU = preload("res://scenes/ui/settings_menu.tscn")

func _on_play_pressed() -> void:
	if get_tree().paused:
		get_tree().paused = false
	
	_transition_to_scene(_1_ST_PLAYABLEWORLD.resource_path)

func _transition_to_scene(scene_path):
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file(scene_path)
	
func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_options_pressed() -> void:
	var settings = SETTINGS_MENU.instantiate()
	get_tree().get_root().add_child(settings)
