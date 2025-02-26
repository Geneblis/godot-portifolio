extends Camera2D

@export var shake_duration: float = 0.5 # Duração em segundos
@export var shake_intensity: float = 10.0 #Intensidade para o offset

var shake_timer: float
var randomizer: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	randomizer.randomize()

func _process(delta: float) -> void:
	if shake_timer > 0:
		shake_timer -= delta
		
		offset = Vector2( #aleatorizador da intensidade, apenas aleatoriza a distancia n a intensidade por mesmo.
			randomizer.randf_range(-shake_intensity, shake_intensity),
			randomizer.randf_range(-shake_intensity, shake_intensity)
		)
	else:
		offset = Vector2.ZERO

func _on_player_player_camera_shake() -> void:
	start_shake()

func start_shake(duration: float = 0.5, intensity: float = 10.0) -> void:
	shake_timer = shake_duration
	intensity = shake_intensity
