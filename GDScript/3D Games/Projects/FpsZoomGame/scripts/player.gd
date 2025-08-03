extends CharacterBody3D

const SAVE_PATH := "user://weapons_save.ini"
@onready var head = $HeadNode
@onready var cam  = $HeadNode/Camera3D
@onready var hand: Node3D = $HeadNode/Camera3D/Hand

const MOUSE_SENSIVITY = 0.2
const GRAVITY = 10
const JUMP_SPEED = 4
const SPEED = 7.0
const ACCEL = 8.0

#starting values
var currentvel = Vector3.ZERO
var velocity_y = 0
var mouse_locked = true
var mouse_input : Vector2

#viewbob
const BOB_FREQ = 1.8
const BOB_AMP = 0.05
var bob_speed = 0.0 

#weaponsway
@export var weapon_holder: Node3D
var def_weapon_holder_pos: Vector3
var weapon_sway_amount: float = 1.25
var weapon_rotation_amount: float = 0.2
var cam_sway_amount: float = 1.0
var cam_rotation_amount: float = 0.175

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	def_weapon_holder_pos = weapon_holder.position
#	end

func _physics_process(delta: float) -> void:
	var dir_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var dir_z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	var input_dir = Vector2(dir_x, dir_z).normalized()
	tilt(input_dir.x, delta)
	
	
	var target_velocity = (global_transform.basis.x * input_dir.x + global_transform.basis.z * input_dir.y) * SPEED
	
	currentvel = currentvel.lerp(target_velocity, ACCEL * delta)
	velocity.x = currentvel.x
	velocity.z = currentvel.z
	
	if Input.is_action_just_pressed("esc"):
		if mouse_locked == true:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouse_locked = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouse_locked = true

	
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity_y = JUMP_SPEED
		else:
			velocity_y = 0
	else:
		velocity_y -= GRAVITY * delta
	
	velocity.y = velocity_y
	move_and_slide()
	
	
	# camera bob
	bob_speed += delta * velocity.length() * float(is_on_floor())
	cam.position = headbob(bob_speed)
	cam.get_child(0).position = headbob(bob_speed)
	sway(delta)
#	end

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: # movimento da camera relativo ao mouse
		head.rotate_x(deg_to_rad(event.relative.y * -MOUSE_SENSIVITY))
		head.rotation_degrees.x = clamp(head.rotation_degrees.x, -90, 60)
		self.rotate_y(deg_to_rad(event.relative.x * -MOUSE_SENSIVITY))
		mouse_input = event.relative
		
	if event.is_action_pressed("save"):
		_save_weapons_to_file()
	elif event.is_action_pressed("load"):
		_load_weapons_from_file()
#	end

func headbob(speed): #begin
	var pos = Vector3.ZERO
	pos.y = sin(speed * BOB_FREQ) * BOB_AMP
	pos.x = sin(speed * BOB_FREQ/2) * BOB_AMP
	return pos
#	end

func tilt(inputx, delta):
	if weapon_holder:
		weapon_holder.rotation.z = lerp(weapon_holder.rotation.z, -inputx * weapon_rotation_amount, 10 * delta)
	if cam:
		cam.rotation.z = lerp(head.rotation.z, -inputx * cam_rotation_amount, 10 * delta)

func sway(delta):
	if weapon_holder:
		mouse_input = lerp(mouse_input,Vector2.ZERO,10*delta)
		weapon_holder.rotation.x = lerp(weapon_holder.rotation.x, mouse_input.y * 
		(weapon_rotation_amount/16), 10 * delta)
		weapon_holder.rotation.y = lerp(weapon_holder.rotation.y, mouse_input.x * 
		(weapon_rotation_amount/16), 10 * delta)

#region Salvamento e Carregamento com ConfigFile
func _save_weapons_to_file() -> void:
	var cfg := ConfigFile.new() # É tipo um container temporario para salvar oq ira salvar no arquivo.
	cfg.load(SAVE_PATH) #Le o arquivo q ja existe

	var inventory_status := []
	for weapon in hand.get_children():
		var ds = weapon.get("dup_state")
		if ds != null:
			inventory_status.append({
				"weapon_name":  ds.weapon_name,
				"current_ammo": ds.current_ammo,
				"reserve_ammo": ds.reserve_ammo
			})

	# Só altera a seção e a chave que você quer, Grava o Array<Dictionary> na seção "weapons", chave "inventory_status"
	cfg.set_value("weapons", "inventory_status", inventory_status)

	# Grava tudo de volta, incluindo seções que você não tocou
	var err = cfg.save(SAVE_PATH)
	if err != OK:
		push_error("❌ Não foi possível salvar em %s" % SAVE_PATH)
	else:
		print("✅ Weapons saved:", inventory_status)


func _load_weapons_from_file() -> void:
	var cfg := ConfigFile.new()
	var err = cfg.load(SAVE_PATH)
	if err != OK:
		print("⚠️ Nenhum arquivo de save encontrado em", SAVE_PATH)
		return

	# Recupera o Array<Dictionary> salvo ou usa lista vazia
	var inventory_status = cfg.get_value("weapons", "inventory_status", [])
	if typeof(inventory_status) != TYPE_ARRAY:
		push_error("Formato inválido: esperava um Array de Dictionary em 'inventory_status'")
		return

	# Aplica cada entrada de volta aos dup_state das armas na cena
	for entry in inventory_status:
		var name = entry.get("weapon_name", "")
		for weapon in hand.get_children():
			var ds = weapon.get("dup_state")
			if ds != null and ds.weapon_name == name:
				ds.current_ammo = entry.get("current_ammo", ds.current_ammo)
				ds.reserve_ammo = entry.get("reserve_ammo", ds.reserve_ammo)
	print("✅ Weapons loaded!")
#endregion
