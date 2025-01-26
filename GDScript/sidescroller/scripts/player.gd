extends CharacterBody2D

signal player_camera_shake
signal update_player_hud

@export var total_aval_ammo:int = 10
var current_aval_ammo: int = 0
const SPEED:float = 200.0
const JUMP_VELOCITY:float = -420.0
var is_jumping:bool = false
var is_shooting:bool = false
var is_reloading:bool = false
enum PlayerState { IDLE, RUN, JUMP, SHOOT, RELOAD } #colocar todos os estados aqui
var current_state = PlayerState.IDLE  #estado inicial
var step_elapsed: float = 0.0

@onready var camera_2d_2: Camera2D = $Camera2D2

#annotations de nodes para instanciamentos
@onready var health: Node2D = $healthmodule
@onready var sprite: AnimatedSprite2D = $sprite
@onready var player_collision: CollisionShape2D = $CollisionShape2D
@onready var bullet_marker: Marker2D = $bulletMarker
@onready var casing_marker: Marker2D = $casingMarker

#sons
@onready var footstep_player: AudioStreamPlayer2D = $FootstepPlayer
@onready var jumper_player: AudioStreamPlayer2D = $JumperPlayer
@onready var shoot_player: AudioStreamPlayer2D = $ShootPlayer
@onready var overheating_player: AudioStreamPlayer2D = $OverheatingPlayer
@onready var reload_player: AudioStreamPlayer2D = $ReloadPlayer

#outros
@onready var shoot_timer: Timer = $shootTimer
@onready var reload_timer: Timer = $reloadTimer
const BULLET = preload("res://scenes/entities/bullet.tscn")
const BULLETCASING = preload("res://scenes/entities/bulletcasing.tscn")
const PAUSEMENU = preload("res://scenes/ui/pausemenu.tscn")

func _pause_game():
	get_tree().paused = true
	
	var pause_menu_instance = PAUSEMENU.instantiate()
	get_tree().get_root().add_child(pause_menu_instance)

# Funcao executada assim que o jogo inicia
func _ready():
	current_aval_ammo = total_aval_ammo
	pass

# Funcao do projetil da bala
func _player_shoot() -> void:
	if current_aval_ammo != 0:
		is_shooting = true
		_play_animation(PlayerState.SHOOT)
		shoot_player.play()
		shoot_timer.start()  # Chamará _on_shoot_timer_timeout
		_spawn_bullet() #spawna a bala da cena BULLET
		
		current_aval_ammo -= 1
		
		#usado para o player_ui
		update_player_hud.emit()
		
		#usado para scripts envolvem a camera
		player_camera_shake.emit()
		
	else:
		overheating_player.play()
		pass
	
func _on_shoot_timer_timeout() -> void:
	is_shooting = false

# Funcao para tocar sons de movimento
func _handle_footsteps(delta: float) -> void:
	if is_on_floor():
		step_elapsed += delta
		if step_elapsed >= 0.6:  # Sons não podem ser maiores que 0.6 segundos
			footstep_player.play()
			step_elapsed = 0.0  # Reseta o timer do som de volta a 0

# Funcao para tocar animacoes baseado no state (enum) do player
func _play_animation(animation_name: PlayerState) -> void:
	if current_state != animation_name:
		current_state = animation_name  #estado atual
		match animation_name:
			PlayerState.IDLE:
				sprite.play("idle")
			PlayerState.RUN:
				sprite.play("run")
			PlayerState.JUMP:
				sprite.play("jump")
			PlayerState.SHOOT:
				sprite.play("shoot")
			PlayerState.RELOAD:
				sprite.play("reload")

func _spawn_bullet():
	# Instanciar a bala e configurar posição e direção
	var bulletin = BULLET.instantiate()
	bulletin.position = bullet_marker.global_position  # A bala spawna na posição do marker2d
	#print(bulletin.position)
	
	_spawn_bullet_casing()
	
	#logica do sprite está no script da bala
	if sprite.flip_h:
		bulletin.direction = Vector2(-1, 0)  # Direção para a esquerda
	else:
		bulletin.direction = Vector2(1,0)
		#END
	get_tree().current_scene.add_child(bulletin)
	
func _spawn_bullet_casing():
	var casign = BULLETCASING.instantiate()
	casign.position = casing_marker.global_position 
	if sprite.flip_h:
		casign.direction = Vector2(1, 0)
	else:
		casign.direction = Vector2(-1,0)
		#END
	get_tree().current_scene.add_child(casign)

func _player_reload(): #aperte R para recarregar
	reload_player.play()
	_play_animation(PlayerState.RELOAD)
	reload_timer.start()
	is_reloading = true

func _on_bullet_timer_timeout() -> void: #mecanica de recarrega
	update_player_hud.emit()
	reload_player.play() #sim, toca 2 vezes.
	is_reloading = false
	current_aval_ammo = total_aval_ammo
	if current_aval_ammo == total_aval_ammo:
		reload_timer.stop()

# Funcao para movimentacao e controles do jogador
func _player_movements(delta: float) -> void:
	# Adicionar gravidade.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Reseta flag de pulo && animacao caso esteja no chao 
	if is_on_floor() && is_jumping == true && ! is_shooting && ! is_reloading:
		is_jumping = false
		_play_animation(PlayerState.IDLE)
	
	# Apenas pode pular caso esteja no chao
	if Input.is_action_just_pressed("ui_up") && is_on_floor() && ! is_reloading:
		_play_animation(PlayerState.JUMP)
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		jumper_player.play()

	# -1 para a esquerda.
	# 1 para a direita.
	# 0 para ficar parado.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0 && not is_reloading:  # Jogador nao pode recarregar para poder se mover
		velocity.x = direction * SPEED
		if not is_jumping && not is_shooting: #nao quebra as animacoes
			_play_animation(PlayerState.RUN)
			_handle_footsteps(delta)
			
		#efeitos para a hitbox seguir o sprite
		#altera o sprite e a posicao de umas parada ai
		#esta indo para a esquerda
		if direction == 1:
			sprite.flip_h = direction < 0
			player_collision.position.x = -9
			bullet_marker.position.x = 8
		#esta indo para a esquerda
		if direction == -1:
			sprite.flip_h = direction < 0
			player_collision.position.x = 9
			bullet_marker.position.x = -8
			
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor() && not is_jumping && not is_shooting && not is_reloading:
			_play_animation(PlayerState.IDLE)
			
	# Apenas pode atirar caso não esteja se movendo, recarregando ou no ar
	if Input.is_action_just_pressed("ui_accept") && not is_reloading && direction == 0:
		_player_shoot()
		
	if Input.is_action_just_pressed("ui_cancel"):
		_pause_game()
	
	if Input.is_action_just_pressed("reload") && is_on_floor() && not is_reloading:
		if current_aval_ammo == total_aval_ammo:
			pass
		else:
			_player_reload()

func _physics_process(delta: float) -> void:
	_player_movements(delta)
	move_and_slide()
