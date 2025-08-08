extends CharacterBody3D

@export var target: Node3D                 # set in main scene
@export var model: Node3D
@export var sight: RayCast3D
@export var anims: AnimationPlayer
@export var agent: NavigationAgent3D
@export var animation_tree: AnimationTree
@export var health_node: Node

@onready var current_state_text: Label3D = $DebugStates
@onready var current_state_text_2: Label3D = $DebugFlags

enum STATE { IDLE, MOVING, PRONE, PRONESHOOT, HIT, DEAD }
var current_state : STATE = STATE.IDLE

# flags
var died: bool = false
var seeing: bool = false
var target_detected: bool = false
var crouching: bool = false
var shot_scheduled: bool = false
var damage_taken: bool = false
var last_seen: Vector3

func _ready() -> void:
	if health_node:
		health_node.char_changed_health.connect(_on_taken_damage)
		health_node.char_died.connect(_on_death)

func _on_death() -> void:
	died = true
	_match_state(STATE.DEAD)

func _on_taken_damage() -> void:
	damage_taken = true
	_match_state(STATE.HIT)

# Entradas/saídas de estado centralizadas
func _match_state(new_state: STATE) -> void:
	if new_state == current_state:
		return
	_exit_state(current_state)
	current_state = new_state
	_enter_state(current_state)

func _enter_state(s: STATE) -> void:
	match s:
		STATE.IDLE:
			target_detected = false
			crouching = false
			# anims.play("Idle") etc.
		STATE.MOVING:
			crouching = false
			# anims.play("WalkingStandLoop")
		STATE.PRONE:
			crouching = true
			# anims.play("GoingProne")
		STATE.PRONESHOOT:
			# schedule shot (async)
			_start_prone_shoot_cycle()
		STATE.HIT:
			crouching = false
			seeing = false
			# anima de hit
			_start_hit_recovery()
		STATE.DEAD:
			target_detected = false
			seeing = false
			died = true
			damage_taken = true
			_start_death_sequence()

func _exit_state(s: STATE) -> void:
	# limpezas ao sair de estados
	if s == STATE.PRONESHOOT:
		# deixa a flag livre para novo ciclo
		shot_scheduled = false
	if s == STATE.HIT:
		damage_taken = false

# --- coroutines / timers seguros ---

# quando entrar em PRONESHOOT, chamamos essa função assíncrona
func _start_prone_shoot_cycle() -> void:
	if shot_scheduled:
		return
	shot_scheduled = true
	# ciclo de tempo aleatório (não bloqueia o jogo)
	# aguardamos sem usar connect/ signals
	var delay = randf_range(1.0, 2.0)
	await get_tree().create_timer(delay).timeout
	# ao acordar, verifique se ainda faz sentido atirar
	if not (current_state == STATE.PRONESHOOT and seeing and not damage_taken and not died):
		shot_scheduled = false
		return
	# realiza o tiro
	_perform_prone_shot()
	shot_scheduled = false
	# opcional: se quiser disparos repetidos, você pode re-entrar no ciclo:
	# if current_state == STATE.PRONESHOOT:
	#     _start_prone_shoot_cycle()

func _perform_prone_shot() -> void:
	# força atualizar o raycast
	if sight:
		sight.force_raycast_update()
	if sight and sight.is_colliding() and sight.get_collider() == target:
		var health_node_t = null
		if target.has_node("Health"):
			health_node_t = target.get_node("Health")
		if health_node_t and health_node_t.has_method("apply_damage"):
			var damage_amount = randi_range(4, 10)
			health_node_t.apply_damage(damage_amount)
			print("Tiro acertou! Vida agora:", health_node_t.current_health)
		else:
			push_error("Health não encontrado ou sem método apply_damage")
	else:
		print("Tiro errou.")

# hit recovery
func _start_hit_recovery() -> void:
	# aguarda 1s, depois limpa damage_taken (e volta ao IDLE ou MOVING conforme visão)
	await get_tree().create_timer(1.0).timeout
	damage_taken = false
	# se ainda existe target_detected, forçar re-avaliação
	if target_detected and not died:
		_match_state(STATE.MOVING)
	else:
		_match_state(STATE.IDLE)

# death sequence
func _start_death_sequence() -> void:
	await get_tree().create_timer(1.9).timeout
	queue_free()

# --- lógica de movimento / visão ---

func _physics_process(delta: float) -> void:
	#current_state_text.text = str(current_state)
	#current_state_text_2.text = "Flags:\n damage_taken: %s\n seeing: %s\n crouching: %s" % [str(damage_taken), str(seeing), str(crouching)]

	# visão
	if sight and target:
		sight.look_at(target.global_position)
		sight.rotation.y = clamp(sight.rotation.y, -PI/2, PI/2)
		if sight.is_colliding() and not died:
			if sight.get_collider() == target:
				last_seen = target.global_position
				target_detected = true
				seeing = true
			else:
				seeing = false
		else:
			seeing = false

	# se morreu, força estado
	if died and current_state != STATE.DEAD:
		_match_state(STATE.DEAD)
		return

	# apenas reaja se não estiver em HIT/DEAD
	if current_state == STATE.HIT or current_state == STATE.DEAD:
		return

	# decisões de comportamento quando o target foi detectado
	if target_detected and not damage_taken:
		# prioridade: se estamos vendo e não estamos ainda agachados -> ir para PRONE
		if seeing and not crouching:
			# rotaciona para mirar
			rotate_y(sight.rotation.y * delta * 40)
			_match_state(STATE.PRONE)
			velocity = Vector3.ZERO
			# próxima iteração vai ver que crouching==true; se ainda estiver vendo, irá para PRONESHOOT
			return

		# se perdemos visão mas estamos agachados, ficamos prontos (stand up)
		if not seeing and crouching:
			crouching = false
			velocity = Vector3.ZERO
			_match_state(STATE.MOVING)
			return

		# se estamos vendo e já agachados -> atirar
		if seeing and crouching:
			# assegura que entramos no estado de tiro
			rotate_y(sight.rotation.y * delta * 40)
			_match_state(STATE.PRONESHOOT)
			velocity = Vector3.ZERO
			return

		# caso geral: perseguir último visto
		_match_state(STATE.MOVING)
		_run(delta)
	else:
		# sem target detectado
		_match_state(STATE.IDLE)

func _run(_delta: float) -> void:
	if not agent: return
	agent.target_position = last_seen
	if agent.is_navigation_finished():
		velocity = Vector3.ZERO
		_match_state(STATE.IDLE)
	else:
		var next_pos: Vector3 = agent.get_next_path_position()
		var dir = (next_pos - global_position).normalized()
		velocity = dir * 2.0
	move_and_slide()
