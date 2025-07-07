extends Node3D

const ENEMY_PMC = preload("res://scenes/enemy_pmc.tscn")
@onready var enemy_spawner: Marker3D = $Entities/EnemySpawner

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() == 0:
		push_error("'Player' group está vazio!")
		return
		
	for i in enemy_spawner.get_children():
		call_deferred("_spawn_enemy", players[0] as Node3D, i as Marker3D)

func _spawn_enemy(target_player: Node3D, child: Marker3D) -> void:
	var enemy = ENEMY_PMC.instantiate() as CharacterBody3D
	add_child(enemy)
	enemy.global_position = child.global_position
	enemy.target = target_player
	
