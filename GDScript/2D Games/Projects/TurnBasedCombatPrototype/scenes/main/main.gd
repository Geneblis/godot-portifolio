# Main.gd
#----------------------------------------------
# Coloque os soldados dentro do array deste nó. 
#----------------------------------------------
extends Node2D
class_name Main

# Grids para posicionar unidades na cena (4x2 cada)
@onready var player_grid: UnitGrid = $PlayerGrid
@onready var enemy_grid:  UnitGrid = $EnemyGrid
@onready var game_handler: GameHandler = $GameHandler

# Exporta arrays de PackedScene pra instanciar Soldados únicos
@export var player_soldier_scenes: Array[PackedScene] = []
@export var enemy_soldier_scenes:  Array[PackedScene] = []


# Máximo de unidades por grid
const MAX_UNITS := 8

func _ready():
	randomize()

	# Limita a lista de cenas a MAX_UNITS elementos
	var scenes_to_instantiate := []
	
	# --- Jogador ---
	scenes_to_instantiate = player_soldier_scenes
	if scenes_to_instantiate.size() > MAX_UNITS:
		scenes_to_instantiate = scenes_to_instantiate.slice(0, MAX_UNITS)
	var soldiers: Array[Node2D] = []
	for scene in scenes_to_instantiate:
		var unit = scene.instantiate()
		soldiers.append(unit)

	# --- Inimigo ---
	scenes_to_instantiate = enemy_soldier_scenes
	if scenes_to_instantiate.size() > MAX_UNITS:
		scenes_to_instantiate = scenes_to_instantiate.slice(0, MAX_UNITS)
	var enemies: Array[Node2D] = []
	for scene in scenes_to_instantiate:
		var unit = scene.instantiate()
		enemies.append(unit)

	# Posiciona e popula o grid do jogador à esquerda
	player_grid.position = player_grid.global_position
	player_grid.populate(soldiers)

	# Posiciona e popula o grid do inimigo à direita
	enemy_grid.position = enemy_grid.global_position
	enemy_grid.populate(enemies)
	
	
	print("Unidades do jogador:", player_grid.get_child_count())
	print("Unidades do inimigo:", enemy_grid.get_child_count())
	game_handler.begin_game()
	print("Começando jogo...")
