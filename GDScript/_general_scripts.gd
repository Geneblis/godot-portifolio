var Player_Canvas = get_tree().get_root().find_child("DamageCanvasPlayer", true, false)


#timer.timeout.connect(_on_timer_timeout)

health_module.char_changed_health.connect(_on_char_changed_health)

health_module.connect("char_changed_health", Callable(self, "_on_char_changed_health"))