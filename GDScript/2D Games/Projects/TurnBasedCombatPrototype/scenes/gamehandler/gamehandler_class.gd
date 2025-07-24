# GameHandler.gd
#----------------------------------------------
# Controla a ordem de turnos e seleção de unidades
# via dado de 8 lados (roll 1–8). É filho de Main,
# e referencia PlayerGrid e EnemyGrid como irmãos.
#----------------------------------------------
extends Node2D
class_name GameHandler

# Paths para os grids (ajuste no Inspector)
@export var player_grid_path: NodePath
@export var enemy_grid_path: NodePath

# Referências aos grids instanciados
var player_grid: Node2D
var enemy_grid: Node2D

# Enum para turno atual
enum Turn { PLAYER, ENEMY }
var current_turn: Turn

func begin_game() -> void:
	randomize()
	
	# Resolvendo referências aos grids
	player_grid = get_node(player_grid_path)
	enemy_grid  = get_node(enemy_grid_path)
	# Decide quem começa e inicia
	_decide_first_turn()

# Escolhe aleatoriamente quem começa: PLAYER ou ENEMY
func _decide_first_turn() -> void:
	if randi() % 2 == 1:
		current_turn = Turn.PLAYER
	else:
		current_turn = Turn.ENEMY
	_start_turn()

# Inicia o turno atual
func _start_turn() -> void:
	match current_turn:
		Turn.PLAYER:
			print("=== Turno do Jogador ===")
			_take_turn(player_grid)
		Turn.ENEMY:
			print("=== Turno do Inimigo ===")
			_take_turn(enemy_grid)

func _take_turn(grid: Node2D) -> void: # Roda o dado de 1 a 8 até achar uma unidade viva para atuar
	var units = grid.get_children()
	var selected: Node2D = null
	
	# Verifica se há pelo menos um vivo

	var has_alive := false
	for u in units:
		if u.has_method("is_alive") and u.is_alive():
			has_alive = true
			break

	if not has_alive:
		print("Nenhuma unidade viva no grid. Pulando turno.")
		_end_turn()
		return

	while selected == null:
		var roll = (randi() % 8)
		if roll < units.size():
			var candidate = units[roll]
			if candidate.has_method("is_alive") and candidate.is_alive():
				selected = candidate
				print("Rolagem: %d -> selecionou %s" % [roll + 1, selected.name])
				break

	# Aqui você NÃO deve chamar _end_turn() ainda
	# Você deve esperar o selected tomar uma ação,
	# e depois chamar _end_turn() dentro dessa ação.
	# Por enquanto, simule isso com um pequeno delay:

	await get_tree().create_timer(0.5).timeout
	_end_turn()
	

# Final de um turno: alterna e chama o próximo
func _end_turn() -> void:
	if current_turn == Turn.PLAYER:
		current_turn = Turn.ENEMY
	else:
		current_turn = Turn.PLAYER

	# Checa vitória/derrota
	if _check_end_condition():
		return
	# Continua o loop de turnos
	_start_turn()

# Retorna true se o combate acabou
func _check_end_condition() -> bool:
	# Verifica se um lado não tem mais unidades vivas
	var player_alive = _any_alive(player_grid)
	var enemy_alive  = _any_alive(enemy_grid)
	if not player_alive:
		print("🚩 Todos os soldados do jogador foram eliminados!")
		return true
	if not enemy_alive:
		print("🏆 Todos os inimigos foram derrotados!")
		return true
	return false

# Helper: existe algum filho vivo com is_alive()==true?
func _any_alive(grid: Node2D) -> bool:
	for u in grid.get_children():
		if u.has_method("is_alive") and u.is_alive():
			return true
	return false
