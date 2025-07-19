extends CharacterBody3D

@export var target: Node3D                 #set in main-scene

@export var model: Node3D                  #normally a node named Assets with all visuals
@export var sight: RayCast3D
@export var anims: AnimationPlayer
@export var agent: NavigationAgent3D
@export var animation_tree: AnimationTree

#troca tudo por exports
enum STATE {IDLE, MOVING, PRONE, PRONESHOOT, HIT, DEAD}
var current_state = STATE.IDLE

#region State Flags
var died: bool = false
var seeing: bool = false
var target_detected: bool = false
var crouching: bool = false
var last_seen: Vector3 
#endregion

func _match_state(new_state: STATE):
	if new_state == current_state:
		return
	current_state = new_state
	
	if current_state == STATE.IDLE:
		target_detected = false
		#anims.play("IdleLoop1")
	elif current_state == STATE.MOVING:
		crouching = false
		#anims.play("WalkingStandLoop")
	elif current_state == STATE.PRONE:
		crouching = true
		#anims.play("GoingProne")
	elif current_state == STATE.PRONESHOOT:
		pass
		#anims.play("ShootingLoop")
	elif current_state == STATE.HIT:
		pass
		#anims.play("CrouchFlinch")
	elif current_state == STATE.DEAD:
		#anims.play("Death1")
		target_detected = false
		seeing = false
		died = true
		await get_tree().create_timer(3.0).timeout
		queue_free()

func _physics_process(delta: float) -> void:
	#debug
	#print("State: " + str(current_state) + "\nseeing: " + str(seeing) + "\ncrouching: " + str(crouching))
	
	# vision cone
	sight.look_at(target.global_position)
	sight.rotation.y = clamp(sight.rotation.y, -PI/2, PI/2)

	# if enemy has died
	if died:
		if current_state != STATE.DEAD:
			_match_state(STATE.DEAD)

	# if vision sees player...
	if sight.is_colliding() and not died:
		if sight.get_collider() == target:
			last_seen = target.global_position
			target_detected = true
			seeing = true
		else:
			seeing = false
	else:
		seeing = false

	# if player was spotted
	if target_detected and not died:
		if seeing and not crouching:
			rotate_y(sight.rotation.y * delta * 40)
			_match_state(STATE.PRONE)
			velocity = Vector3.ZERO

		elif not seeing and crouching:
			crouching = false
			velocity = Vector3.ZERO

		elif seeing and crouching:
			rotate_y(sight.rotation.y * delta * 40)
			_match_state(STATE.PRONESHOOT)
			velocity = Vector3.ZERO

		else:
			_match_state(STATE.MOVING)
			run(delta)

func run(delta: float) -> void:
	agent.target_position = last_seen
	if agent.is_navigation_finished():
		velocity = Vector3.ZERO
		_match_state(STATE.IDLE)
	else:
		var next_pos: Vector3 = agent.get_next_path_position()
		var dir = (next_pos - global_position).normalized()
		velocity = dir * 2.0
	move_and_slide()
