extends CanvasLayer

const SETTINGS_MENU = preload("res://scenes/ui/settings_menu.tscn")

#func _ready() -> void:
#	pass # Replace with function body.

func _on_continue_pressed() -> void:
	get_tree().paused = false
	self.queue_free()


func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_options_pressed() -> void:
	var settings = SETTINGS_MENU.instantiate()
	get_tree().get_root().add_child(settings)
