#NOTE: this code is very bad, I know. I regret creating it. I fear refactoring it.
#I have nightmares of this code, I'm unware of it's replicability and I will not utilize anything
#of it outside of this scope. Forgive me dear father whom art in Heaven, I shall not repeat my sins.

extends CharacterBody2D

const SPEED: float = 84.0
const JUMP_VELOCITY: float = -400.0

@onready var health: Node2D = $healthmodule
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var area_of_active: Area2D = $AreaOfActive
@onready var attack_timer: Timer = $AttackTimer
@onready var death_timer: Timer = $DeathTimer

signal enemy_damaged_player

var obstacles: Array = []
var is_actually_dead: bool = false
var is_attacking: bool = false
var player: CharacterBody2D = null
var is_chasing: bool = false
var current_animation: EntityState = EntityState.IDLE

enum EntityState {
	IDLE,
	CHASING,
	ATTACKING
}

func _ready() -> void:
	area_of_active.body_entered.connect(_on_area_of_active_area_entered)
	area_of_active.body_exited.connect(_on_area_of_active_area_exited)
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	match current_animation:
		EntityState.IDLE:
			if is_chasing:
				_enemy_play_animation(EntityState.CHASING)
		EntityState.CHASING:
			if is_attacking:
				_enemy_play_animation(EntityState.ATTACKING)
			elif not is_chasing:
				_enemy_play_animation(EntityState.IDLE)
			else:
				_chase_player(delta)
		EntityState.ATTACKING:
			if not is_attacking:
				_enemy_play_animation(EntityState.IDLE)
	move_and_slide()

func _enemy_play_animation(animation_name: EntityState) -> void:
	if current_animation == animation_name:
		return
	current_animation = animation_name
	match current_animation:
		EntityState.IDLE:
			sprite.play("idle")
		EntityState.CHASING:
			sprite.play("run")
		EntityState.ATTACKING:
			sprite.play("attack")
			
func _chase_player(delta: float) -> void:
	var has_reached_player_x: bool = false
	if is_attacking == false:
		var direction_to_player = sign(player.global_position.x - global_position.x)
		var avoidance_velocity = calculate_rvo_velocity()
		velocity.x = direction_to_player * SPEED + avoidance_velocity.x
		if abs(player.global_position.x - global_position.x) <= 1:
			velocity.x = 0
			_enemy_play_animation(EntityState.IDLE)
			has_reached_player_x = true
		if abs(player.global_position.x - global_position.x) > 9 and has_reached_player_x:
			has_reached_player_x = false
		if is_attacking == false and has_reached_player_x == false:
			_update_sprite_direction(direction_to_player)

func _idle_behavior(delta: float) -> void:
	velocity.x = 0

func _update_sprite_direction(direction: int) -> void:
	sprite.flip_h = direction > 0
	
func _on_area_of_active_area_entered(body: Node):
	if body is CharacterBody2D and body.name == "player":
		player = body #this is mandantory, dont ask!
		is_chasing = true
		
func _on_area_of_active_area_exited(body: Node): #player left radius
	if body == player:
		velocity.x = 0 #stop moving
		player = null
		is_chasing = false
		
func _on_area_of_attack_body_entered(body: Node2D): #Enemy has reached inner area of attack
	if body is CharacterBody2D and body.name == "player" and not is_actually_dead:
		#lazy ass combat, ik
		var direction_to_player = sign(player.global_position.x - global_position.x)
		
		body.velocity.y = -180
		
		if direction_to_player == -1: #frente
			body.global_position.x = (global_position.x - 50)
		else:
			body.global_position.x = (global_position.x + 50)
		
		velocity.x = 0 #stop moving
		
		var damage: int = randi_range(4, 8)
		sprite.play("attack")
		player.health.apply_damage(damage)
		attack_timer.start() #_on_attack_timer_timeout
		is_attacking = true
		
		var Player_Canvas = get_tree().get_root().find_child("DamageCanvasPlayer", true, false)
		Player_Canvas.play("damage_screen")
func _on_attack_timer_timeout() -> void:
	is_attacking = false
	
func _on_enemy_death() -> void: #check healthmodule
	death_timer.start()
	is_actually_dead = true
	velocity.x = 0 #stop moving
	
func _on_death_timer_timeout() -> void:
	self.queue_free()
	
func calculate_rvo_velocity() -> Vector2:
	var avoidance = Vector2.ZERO
	for obstacle in obstacles:
		var relative_position = obstacle.global_position - global_position
		var relative_velocity = obstacle.velocity - velocity
		if relative_position.length() < 32.0:
			var avoidance_direction = relative_position.normalized().orthogonal()
			var avoidance_strength = (32.0 - relative_position.length()) / 32.0
			avoidance += avoidance_direction * avoidance_strength * SPEED
	return avoidance
	
func _on_obstacle_entered(body: Node) -> void:
	if body is CharacterBody2D and body != self:
		obstacles.append(body)
		
func _on_obstacle_exited(body: Node) -> void:
	if body in obstacles:
		obstacles.erase(body)
