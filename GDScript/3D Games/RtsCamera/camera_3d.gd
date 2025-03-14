extends Camera3D

@export var move_speed: float = 20.0       # Velocidade de movimento
@export var rotation_speed: float = 0.005   # Sensibilidade da rotação
@export var zoom_speed: float = 5.0         # Sensibilidade do zoom

func _process(delta: float) -> void:
	# Se o botão direito NÃO estiver pressionado, processa o movimento
	if not Input.is_action_pressed("rotate_camera"):
		_process_movement(delta)

func _input(event: InputEvent) -> void:
	# Quando o botão direito estiver pressionado, processa a rotação da câmera
	if Input.is_action_pressed("rotate_camera") and event is InputEventMouseMotion:
		_process_rotation(event)

func _process_movement(delta: float) -> void:
	# Cria um vetor de entrada baseado nas ações WASD
	var input_dir = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_backward"):
		input_dir.z += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	
	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()
		
		# Obter as direções da câmera no plano horizontal:
		# 'forward' é a direção da frente da câmera, mas ignoramos a componente Y
		var forward = -global_transform.basis.z
		forward.y = 0
		forward = forward.normalized()
		# 'right' é a direção direita da câmera
		var right = global_transform.basis.x
		right.y = 0
		right = right.normalized()
		
		# Calcula o movimento baseado no vetor de entrada
		var movement = (right * input_dir.x + forward * input_dir.z) * move_speed * delta
		translate(movement)
	else:
		# Se não houver entrada, não move nada
		pass

func _process_rotation(event: InputEventMouseMotion) -> void:
	# Rotação horizontal: gira em torno do eixo Y
	rotate_y(-event.relative.x * rotation_speed)
	# Rotação vertical: para uma câmera RTS, geralmente você quer limitar a rotação vertical.
	# Vamos atualizar a rotação do ângulo de pitch, mantendo-a dentro de limites.
	var new_pitch = rotation_degrees.x - event.relative.y * rotation_speed * 10.0
	rotation_degrees.x = clamp(new_pitch, -80, -10)  # Limite: não olhar muito para cima ou para baixo
