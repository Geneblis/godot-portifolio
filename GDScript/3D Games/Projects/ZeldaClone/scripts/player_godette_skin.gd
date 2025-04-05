extends Node3D

@onready var AnimTree = $AnimationTree
@onready var move_state_machine = $AnimationTree.get("parameters/MoveStateMachine 2/playback")
@onready var attack_state_machine = $AnimationTree.get("parameters/AttackStateMachine/playback")
@onready var spell_tree = AnimTree.get_tree_root().get_node("Spell")
@onready var attack_timer: Timer = $AttackTimer
@onready var right_hand_slot: BoneAttachment3D = $Rig/Skeleton3D/RightHandSlot
@onready var left_hand_slot: BoneAttachment3D = $Rig/Skeleton3D/LeftHandSlot
@onready var sword_1_handed_2: Node3D = $Rig/Skeleton3D/RightHandSlot/sword_1handed2
@onready var wand: MeshInstance3D = $Rig/Skeleton3D/RightHandSlot/wand2/wand
@onready var face_material: StandardMaterial3D = $Rig/Skeleton3D/Godette_Head.get_surface_override_material(0)
@onready var bliwnk: Timer = $bliwnk

var rng = RandomNumberGenerator.new()

const faces = {
	"default": Vector3.ZERO,
	"blink": Vector3(0,0.5,0)
}


var attacking: bool = false

func _ready() -> void:
	wand.hide()

func _change_face(expression) -> void:
	face_material.uv1_offset = faces[expression]

func _on_bliwnk_timeout() -> void:
	_change_face("blink")
	await get_tree().create_timer(0.2).timeout
	_change_face("default")
	bliwnk.wait_time = rng.randf_range(1.5, 3.0)
	
func  _set_move_state(state_name: String) -> void:
	move_state_machine.travel(state_name)

func _attack() -> void:
	if not attacking:
		attack_state_machine.travel("Slice" if attack_timer.time_left else "Chop")
		AnimTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func _attack_toggle(value: bool):
	attacking = value

func _defend(forward: bool) -> void:
	var tween = create_tween()
	tween.tween_method(_defend_change, 1.0 - float(forward), float(forward), 0.25)
	
func _defend_change(val: float) -> void:
	AnimTree.set("parameters/ShieldBlend/blend_amount", val)
	

func cast_spell() -> void:
	if not attacking:
		spell_tree.animation = "Spellcast_Shoot"
		AnimTree.set("parameters/SpellOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func hit() -> void:
	#changes the spell tree to an hit animation
	spell_tree.animation = "Hit_A"
	AnimTree.set("parameters/SpellOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	AnimTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	attacking = false

func switch_weapon(weapon_active: bool) -> void:
	if weapon_active:
		sword_1_handed_2.show()
		wand.hide()
	else:
		sword_1_handed_2.hide()
		wand.show()
