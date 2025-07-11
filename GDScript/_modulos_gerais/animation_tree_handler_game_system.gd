# Manages AnimationTree nodes based on camera proximity.
# • On ready, scans the current scene and caches all AnimationTree instances.
# • Each frame, measures the distance from the main camera to each tree’s owner node.
# • Activates the AnimationTree if it’s within ‘max_animation_distance’, otherwise disables it.

extends Node

@export var max_animation_distance: float = 50.0

var _animation_trees: Array[AnimationTree] = []
var _camera: Camera3D

func _ready() -> void:
	_camera = get_viewport().get_camera_3d()
	_cache_animation_trees(get_tree().current_scene)
	
func _process(delta: float) -> void:
	if not _camera:
		_camera = get_viewport().get_camera_3d()
		if not _camera:
			return
	var cam_pos = _camera.global_transform.origin
	for anim_tree in _animation_trees:
		if not is_instance_valid(anim_tree):
			continue
		var owner_pos = _find_owner_position(anim_tree)
		var distance  = cam_pos.distance_to(owner_pos)
		anim_tree.active = distance <= max_animation_distance


func _cache_animation_trees(root: Node) -> void:
	if root is AnimationTree:
		_animation_trees.append(root)
	for child in root.get_children():
		_cache_animation_trees(child)

func _find_owner_position(node: Node) -> Vector3:
	while node and not (node is Node3D):
		node = node.get_parent()
	return node.global_transform.origin if node else Vector3.ZERO
