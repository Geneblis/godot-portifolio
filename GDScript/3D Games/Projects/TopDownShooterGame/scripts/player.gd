extends CharacterBody3D

@export var move_speed: float = 10.0
@export var rotation_speed: float = 10.0   # Se quiser interpolar a rotação (opcional)

# Nó que representa o modelo visual do jogador.
@onready var model: MeshInstance3D = $Model
@onready var gun: Node3D = $Model/Node3D/CSGBox3D/RayCast3D

##@onready var traj_inst: MeshInstance3D = gun.get_node("Trajectory")
#@export var traj_color: Color = Color(1,0,0)

var bullet = load("res://scenes/boolet.tscn")
var instance


func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_look_at_mouse()
	
	if Input.is_action_just_pressed("shoot"):
		instance = bullet.instantiate()
		instance.position = gun.global_position
		instance.transform.basis = gun.global_transform.basis
		get_parent().add_child(instance)


func _handle_movement(delta: float) -> void:
	# Aplica gravidade quando o player não está no chão
	if not is_on_floor():
		velocity.y -= 30.0 * delta
	else:
		velocity.y = 0.0
	
	# Obtém o vetor de input, mas inverte o eixo Y para corrigir W/S
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_forwards", "move_backward") * Vector2(1, -1)
	if input_vector != Vector2.ZERO:
		var cam = get_viewport().get_camera_3d()
		var forward: Vector3 = -cam.global_transform.basis.z
		var right: Vector3 = cam.global_transform.basis.x
		forward.y = 0
		right.y = 0
		forward = forward.normalized()
		right = right.normalized()
		var move_dir: Vector3 = (forward * input_vector.y + right * input_vector.x).normalized()
		velocity.x = move_dir.x * move_speed
		velocity.z = move_dir.z * move_speed
	else:
		velocity.x = 0
		velocity.z = 0
	move_and_slide()

func _look_at_mouse() -> void:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return
	
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var ray_origin: Vector3 = cam.project_ray_origin(mouse_pos)
	var ray_dir: Vector3 = cam.project_ray_normal(mouse_pos)

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_dir * 1000)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)

	var look_target: Vector3
	if result:
		# Olha diretamente para onde o mouse está colidindo (ex: inimigo)
		look_target = result.position
	else:
		# Se não colidir com nada, mira para frente do jogador (útil em ladeiras)
		look_target = global_position + velocity.normalized() * 10.0
		look_target.y = global_position.y + 1.5  # opcional: ajusta altura da mira

	# Faz o modelo girar horizontalmente
	var flat_target = look_target
	flat_target.y = global_position.y
	var target_angle = atan2(flat_target.x - global_position.x, flat_target.z - global_position.z) - PI
	model.rotation.y = lerp_angle(model.rotation.y, target_angle, rotation_speed * get_process_delta_time())

	# Faz a arma mirar diretamente no ponto, incluindo altura
	gun.look_at(look_target, Vector3.UP)

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
