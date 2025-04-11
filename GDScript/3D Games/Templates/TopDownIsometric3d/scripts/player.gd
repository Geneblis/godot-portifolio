extends CharacterBody3D

@export var move_speed: float = 10.0
@export var rotation_speed: float = 10.0

# Nó que representa o modelo visual do jogador.
@onready var model: MeshInstance3D = $Model

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_look_at_mouse()

func _handle_movement(delta: float) -> void:
	# Obtém o vetor de input, mas inverte o eixo Y para corrigir W/S
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_forwards", "move_backward") * Vector2(1, -1)
	
	# Gravidade
	if not is_on_floor():
		velocity.y -= 30.0 * delta
	else:
		velocity.y = 0.0
		
	if input_vector != Vector2.ZERO:
		var cam = get_viewport().get_camera_3d()
		
		# Obtém a direção para frente e direita da câmera, ignorando o eixo Y
		var forward: Vector3 = -cam.global_transform.basis.z
		var right: Vector3 = cam.global_transform.basis.x
		forward.y = 0
		right.y = 0
		forward = forward.normalized()
		right = right.normalized()
		
		# Combina os vetores de movimento de acordo com o input do usuário
		var move_dir: Vector3 = (forward * input_vector.y + right * input_vector.x).normalized()
		velocity.x = move_dir.x * move_speed
		velocity.z = move_dir.z * move_speed
	else:
		velocity.x = 0
		velocity.z = 0
	move_and_slide()
	
func _look_at_mouse() -> void:
	var mouse_world_pos: Vector3 = _get_mouse_world_position()
	# Se a posição for válida, faça o modelo olhar para ela, mantendo a altura do jogador.
	if mouse_world_pos != Vector3.ZERO: 
		mouse_world_pos.y = global_position.y
		# Calcula o ângulo alvo, ajustando por -PI para alinhar com o -Z (frente)
		var target_angle = atan2(mouse_world_pos.x - global_position.x, mouse_world_pos.z - global_position.z) - PI
		# Atualiza a rotação do modelo de forma suave
		model.rotation.y = lerp_angle(model.rotation.y, target_angle, rotation_speed * get_process_delta_time())

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
