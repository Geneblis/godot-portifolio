extends Camera3D

# Configurações de movimento da câmera
@export_category("Configurações de movimento da câmera")
@export var camera_speed: float = 20.0  # Velocidade de movimento da câmera.
@export var camera_zoom_speed: float = 20.0  # Velocidade de zoom da câmera.
@export var camera_zoom_min: float = 10.0  # Distância mínima de zoom.
@export var camera_zoom_max: float = 20.0  # Distância máxima de zoom.

# Configurações de rolagem nas bordas
@export_category("Configurações de rolagem nas bordas")
@export var edge_scroll_margin: float = 20.0  # Distância da borda para ativar a rolagem.
@export var edge_scroll_speed: float = 15.0  # Velocidade da rolagem nas bordas.

# Configurações de rotação da câmera
@export_category("Configurações de rotação da câmera")
@export var rotation_speed: float = 0.8

# Propriedades atuais da câmera
var current_height: float = 20.0
var orbit_center: Vector3 = Vector3.ZERO
var orbit_radius: float = 20.0

# Define a posição e rotação inicial da câmera
func _ready():
	_update_camera_position()  # Atualiza a posição da câmera ao iniciar.
	rotation_degrees.x = -45  # Rotação inicial da câmera no eixo X.

func _process(delta: float) -> void:
	var movement = Vector3.ZERO  # Inicializa o vetor de movimento da câmera.
	
	# Captura as teclas de movimento personalizadas
	if Input.is_action_pressed("move_right"):
		movement.x += 1  # Move para a direita.
	if Input.is_action_pressed("move_left"):
		movement.x -= 1  # Move para a esquerda.
	if Input.is_action_pressed("move_forward"):
		movement.z -= 1  # Move para frente.
	if Input.is_action_pressed("move_backward"):
		movement.z += 1  # Move para trás.
	
	#Move o centro da órbita da câmera, verifica se há movimento.
	if movement.length() > 0: 
		movement = movement.normalized() 
		# Rotaciona o movimento com base na rotação atual da câmera (eixo Y)
		movement = movement.rotated(Vector3.UP, rotation.y)
		orbit_center += movement * camera_speed * delta  # Atualiza o centro da órbita.
		_update_camera_position()  # Atualiza a posição da câmera.

func _unhandled_input(event: InputEvent) -> void:
	# Zoom da câmera com a roda do mouse
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			current_height = max(camera_zoom_min, current_height - camera_zoom_speed * get_process_delta_time())  # Zoom in.
			orbit_radius = (current_height * 1.5)
			_update_camera_position()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			current_height = min(camera_zoom_max, current_height + camera_zoom_speed * get_process_delta_time())  # Zoom out.
			orbit_radius = (current_height * 1.5)
			_update_camera_position()

	# Rotação da câmera com o botão direito do mouse 
	elif event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_RIGHT:
		rotate_y(-event.relative.x * rotation_speed * get_process_delta_time())  # Rotaciona a câmera com base no movimento do mouse.
		_update_camera_position()

func _update_camera_position():
	# Calcula a posição da câmera com base nos parâmetros da órbita
	var angle = rotation.y  # Obtém o ângulo de rotação atual da câmera.
	var offset = Vector3(
		sin(angle) * orbit_radius,  # Posição X da câmera.
		current_height,  # Altura atual da câmera.
		cos(angle) * orbit_radius  # Posição Z da câmera.
	)
	position = orbit_center + offset  # Define a posição da câmera em relação ao centro da órbita.
	look_at(orbit_center, Vector3.UP)  # Faz a câmera olhar para o centro da órbita.
