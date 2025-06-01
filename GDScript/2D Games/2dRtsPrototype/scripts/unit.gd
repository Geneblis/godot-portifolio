# Unit.gd
extends CharacterBody2D

@export var move_speed      : float = 200.0
var target_position         : Vector2
var use_navigation_agent    : bool  = false
@onready var agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	# Inicializa target_position para a posição atual
	target_position = global_position

	# Se existir um NavigationAgent2D como filho, vamos usá‐lo
	if has_node("NavigationAgent2D"):
		use_navigation_agent = true
		agent.target_position = global_position

func _set_agent(value):
	agent = value
	use_navigation_agent = true

func select(on: bool) -> void:
	# Exemplo visual simples: modulate do sprite
	if on:
		$Sprite2D.modulate = Color(0.8, 0.8, 1.0)
	else:
		$Sprite2D.modulate = Color(1, 1, 1)
func set_target_position(dest: Vector2) -> void:
	target_position = dest
	if use_navigation_agent:
		agent.target_position = dest

func _physics_process(delta: float) -> void:
	if use_navigation_agent:
		# Se o agente ainda não terminou o caminho, caminhe seguindo-o
		if not agent.is_navigation_finished():
			var nav_next = agent.get_next_path_position()
			var dir = (nav_next - global_position).normalized()
			velocity = dir * move_speed
			move_and_slide()
			return
		else:
			# Chegou ao destino do agente → pare aqui e não mova mais
			velocity = Vector2.ZERO
			return

	# Se não estiver usando NavigationAgent2D, faz um movimento em linha reta
	if global_position.distance_to(target_position) > 4.0:
		var dir = (target_position - global_position).normalized()
		velocity = dir * move_speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
