# Main.gd
#----------------------------------------------
# Nó raiz que carrega as formações diretamente dos UnitGrids
# e dispara o GameHandler para iniciar o combate.
#----------------------------------------------
extends Node2D
class_name Main

@onready var player_grid: UnitGrid    = $PlayerGrid
@onready var enemy_grid:  UnitGrid    = $EnemyGrid
@onready var game_handler: GameHandler = $GameHandler

func _ready() -> void:
	randomize()
	
	# Exibe quantas unidades cada grid já tem (filhas do editor ou carregadas em runtime)
	var count_player = player_grid.get_child_count()
	var count_enemy  = enemy_grid.get_child_count()
	print("Jogador tem %d unidades" % count_player)
	print("Inimigo tem %d unidades"  % count_enemy)
	
	# Inicia o combate usando os filhos atuais dos grids
	game_handler.begin_game()
	print("=== Combate iniciado ===")
