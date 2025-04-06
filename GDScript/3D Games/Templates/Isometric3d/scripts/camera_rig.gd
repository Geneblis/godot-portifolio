extends Node3D

@export var target: Node3D                  # O jogador ou objeto que a câmera deve seguir
@export var orbit_radius: float = 10.0      # Distância horizontal da câmera em relação ao target
@export var orbit_height: float = 10.0      # Altura da câmera em relação ao target
@export var rotation_speed: float = 1.5     # Velocidade de rotação (em radianos por segundo)

var orbit_angle: float = 0.0                # Ângulo atual da câmera em torno do target

func _process(delta: float) -> void:
	# Atualiza o ângulo com base nas teclas Q e E
	if Input.is_action_pressed("rotate_left"):
		orbit_angle += rotation_speed * delta
	if Input.is_action_pressed("rotate_right"):
		orbit_angle -= rotation_speed * delta
	
	# Se houver um target definido, atualize a posição e orientação da câmera
	if target:
		var offset = Vector3(sin(orbit_angle) * orbit_radius, orbit_height, cos(orbit_angle) * orbit_radius)
		global_position = target.global_position + offset
		look_at(target.global_position, Vector3.UP)
