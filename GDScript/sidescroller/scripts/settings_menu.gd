extends CanvasLayer

@onready var volume_contro_label: Label = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/VolumeControLabel
@onready var sound_slider: HSlider = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/VolumeSlider

func _ready() -> void:
	var initial_value = sound_slider.value
	_set_volume(initial_value)

func _on_sound_slider_value_changed(value: float) -> void:
	_set_volume(value)

func _set_volume(value: float) -> void:
	# Converte de 0-100% para -80 dB a 0 dB, regra de 3.
	var db_value = lerp(-80, 0, value / 100.0)
	AudioServer.set_bus_volume_db(0, db_value)
	volume_contro_label.text = ("Volume: ") + str(value) + "%"


func _on_window_mode_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_resolution_screen_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1152, 648))
		1:
			DisplayServer.window_set_size(Vector2i(800, 600))

func _on_screen_shake_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.

func _on_exit_pressed() -> void:
	self.queue_free()
