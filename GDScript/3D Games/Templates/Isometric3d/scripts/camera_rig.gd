extends Node3D

@export var target: Node3D   # Geralmente o nó Player
@export var offset: Vector3 = Vector3(0, 20, -20)   # Ajuste para a perspectiva desejada

func _process(delta: float) -> void:
	if target:
		global_position = target.global_position + offset
		# Manter a rotação fixa para isometria; se quiser que a câmera olhe para baixo, use:
		rotation = Vector3(deg_to_rad(45), 0, 0)
