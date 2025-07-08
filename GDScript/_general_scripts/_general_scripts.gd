var Player_Canvas = get_tree().get_root().find_child("DamageCanvasPlayer", true, false)


#timer.timeout.connect(_on_timer_timeout)

health_module.char_changed_health.connect(_on_char_changed_health)

health_module.connect("char_changed_health", Callable(self, "_on_char_changed_health"))


#RTS 3D Camera
var viewport_size: Vector2

func _ready() -> void:
	viewport_size = get_viewport().size

func _process(delta: float) -> void:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var joy_dir: Vector2 = Vector2.ZERO

	# Checa se o mouse está próximo das bordas
	if mouse_pos.x < edge_scroll_margin:
		joy_dir.x = -1.0
	elif mouse_pos.x > viewport_size.x - edge_scroll_margin:
		joy_dir.x = 1.0
	
	if mouse_pos.y < edge_scroll_margin:
		joy_dir.y = 1.0
	elif mouse_pos.y > viewport_size.y - edge_scroll_margin:
		joy_dir.y = -1.0

	rotate_from_vector(joy_dir * delta * Vector2(horizontal_acceleration, vertical_acceleration))