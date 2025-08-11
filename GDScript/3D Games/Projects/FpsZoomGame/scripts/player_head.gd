extends Node3D
## Procedural recoil system (horizontal + vertical).
## Special thanks to AceSpectre for base code.

# Rotations
var current_rotation: Vector3 = Vector3.ZERO
var target_rotation: Vector3 = Vector3.ZERO

# Recoil values (vertical X, horizontal Y, roll Z)
@export_category("Recoil Settings")
@export var recoil: Vector3 = Vector3.ZERO
@export var aim_recoil: Vector3 = Vector3.ZERO

@export_category("Configuration")
@export var snappiness: float = 10.0       # Recoil speed
@export var return_speed: float = 5.0      # Reset speed
@export var weapons: Node3D                # Weapons node

func _ready() -> void:
	# connect signals (optional)
	for w in weapons.get_children():
		if w.has_signal("weapon_fired"):
			w.weapon_fired.connect(recoil_fire)

func _process(delta: float) -> void:
	target_rotation = target_rotation.lerp(Vector3.ZERO, return_speed * delta)
	current_rotation = current_rotation.lerp(target_rotation, snappiness * delta)

	# Aplica rotação
	rotation = current_rotation
	
	if recoil.z == 0.0 and aim_recoil.z == 0.0:
		global_rotation.z = 0.0

func recoil_fire(is_aiming: bool = false) -> void:
	var base_recoil = aim_recoil if is_aiming else recoil
	target_rotation += Vector3(
		base_recoil.x,
		randf_range(-base_recoil.y, base_recoil.y),
		randf_range(-base_recoil.z, base_recoil.z)
	)

func set_recoil(new_recoil: Vector3) -> void:
	recoil = new_recoil

func set_aim_recoil(new_recoil: Vector3) -> void:
	aim_recoil = new_recoil
