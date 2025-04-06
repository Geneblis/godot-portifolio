extends CharacterBody3D

@export var move_speed: float = 10.0
@export var rotation_speed: float = 10.0   # Se quiser interpolar a rotação (opcional)

# Nó que representa o modelo visual do jogador.
@onready var model: MeshInstance3D = $Model
@onready var model_2: MeshInstance3D = $Model/Model2

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_look_at_mouse()

func _handle_movement(delta: float) -> void:
	# Obtenha o vetor de entrada (supondo que as ações estejam definidas no Input Map)
	var input_vector: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var move_dir: Vector3 = Vector3(input_vector.x, 0, input_vector.y)
	if move_dir != Vector3.ZERO:
		move_dir = move_dir.normalized()
		velocity = move_dir * move_speed
	else:
		velocity = Vector3.ZERO
	
	move_and_slide()
	
	
func _look_at_mouse() -> void:
	# Obtém a posição do mouse no mundo
	var mouse_world_pos: Vector3 = _get_mouse_world_position()
	# Se a posição for válida, faça o modelo olhar para ela, mantendo a altura do jogador.
	if mouse_world_pos != Vector3.ZERO:
		mouse_world_pos.y = global_position.y
		# Calcula o ângulo alvo, ajustando por -PI para alinhar com o -Z (frente)
		var target_angle = atan2(mouse_world_pos.x - global_position.x, mouse_world_pos.z - global_position.z) - PI
		# Atualiza a rotação do modelo de forma suave
		model.rotation.y = lerp_angle(model.rotation.y, target_angle, rotation_speed * get_process_delta_time())
		# Se preferir usar look_at diretamente (pode ser brusco):
		# model.look_at(mouse_world_pos, Vector3.UP)

# Função para projetar o mouse no plano horizontal
func _get_mouse_world_position() -> Vector3:
	var cam: Camera3D = get_viewport().get_camera_3d()
	if cam == null:
		return Vector3.ZERO
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var ray_origin: Vector3 = cam.project_ray_origin(mouse_pos)
	var ray_dir: Vector3 = cam.project_ray_normal(mouse_pos)
	# Suponha que o chão esteja no mesmo nível que o jogador (global_position.y)
	if abs(ray_dir.y) < 0.001:
		return Vector3.ZERO
	var t: float = (global_position.y - ray_origin.y) / ray_dir.y
	return ray_origin + ray_dir * t
