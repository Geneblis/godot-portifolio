extends CharacterBody3D

# Configurações
@export var speed: float = 8.0
@export var camera_rotation_speed: float =  2.0  # Velocidade de rotação da câmera com Q/E

# Referências
@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var camera: Camera3D = $SpringArm3D/Camera3D
@onready var mesh: Node3D = $CollisionShape3D/mixamo_base  # Substitua pelo seu nó do modelo
@onready var collision: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	camera.rotation_degrees = Vector3(10, 0, 0)  # Ângulo fixo da câmera

func _physics_process(delta: float) -> void:
	# Movimento com W/S/A/D
	var input_dir = Input.get_vector("a", "d", "w", "s")
	
	# Vetores da câmera (projetados no plano horizontal)
	var camera_forward = -camera.global_transform.basis.z  # Direção frontal da câmera
	var camera_right = camera.global_transform.basis.x     # Direção direita da câmera
	
	# Remove componente vertical e normaliza
	camera_forward.y = 0
	camera_forward = camera_forward.normalized()
	
	camera_right.y = 0
	camera_right = camera_right.normalized()
	
	# Combina as direções
	var direction = (
		(camera_forward * input_dir.y) +  # W/S (frente/trás)
		(camera_right * input_dir.x)      # A/D (esquerda/direita)
	)
	
	velocity = direction * speed
	move_and_slide()
	

func _input(event: InputEvent) -> void:
	# Rotação do personagem com o mouse
	if event is InputEventMouseMotion:
		var ray_length = 1000
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * ray_length
		var query = PhysicsRayQueryParameters3D.create(from, to)
		var collision = get_world_3d().direct_space_state.intersect_ray(query)
		
		if collision:
			# Corrige a direção oposta e inclinação
			var look_pos = collision.position
			
			# Mantém a rotação apenas no eixo Y
			mesh.look_at(look_pos, Vector3.UP)
			
			# Remove a rotação nos eixos X e Z
			mesh.rotation_degrees.x = 0
			mesh.rotation_degrees.z = 0
			
			# Corrige a direção oposta (180 graus no eixo Y)
			mesh.rotate_y(deg_to_rad(180))
	
	# Rotação da câmera com Q e E
	if Input.is_action_pressed("q"):
		spring_arm.rotation_degrees.y -= camera_rotation_speed
	if Input.is_action_pressed("e"):
		spring_arm.rotation_degrees.y += camera_rotation_speed
