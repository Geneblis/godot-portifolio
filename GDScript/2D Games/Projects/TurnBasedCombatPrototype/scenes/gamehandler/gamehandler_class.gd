# GameHandler.gd
#----------------------------------------------
# Controla turnos e ataques entre unidades em grids 4x2
#----------------------------------------------
extends Node2D
class_name GameHandler

# Paths para os grids (configurar no Inspector)
@export var player_grid_path: NodePath
@export var enemy_grid_path:  NodePath

# Referências aos grids
var player_grid: Node2D
var enemy_grid:  Node2D

# Turnos
enum Turn { PLAYER, ENEMY }
var current_turn: Turn

# Inicia o handler (chamar de Main.gd)
func begin_game() -> void:
	randomize()
	player_grid = get_node(player_grid_path)
	enemy_grid  = get_node(enemy_grid_path)
	decide_first_turn()

# Decide quem começa e inicia o primeiro turno
func decide_first_turn() -> void:
	if randi() % 2 == 1:
		current_turn = Turn.PLAYER
	else:
		current_turn = Turn.ENEMY
	start_turn()

# Executa o turno atual
func start_turn() -> void:
	if current_turn == Turn.PLAYER:
		print("=== Turno do Jogador ===")
		perform_turn(player_grid)
	else:
		print("=== Turno do Inimigo ===")
		perform_turn(enemy_grid)

# Seleciona unidade válida e executa ataque
func perform_turn(grid: Node2D) -> void:
	var candidates := []
	for u in grid.get_children():
		if (u is UnitSoldierClass or u is UnitMechaClass) and u.is_alive():
			candidates.append(u)
	if candidates.size() == 0:
		print("Nenhuma unidade viva. Pulando turno.")
		end_turn()
		return
	var selected = candidates[randi() % candidates.size()]
	print("Selecionado: %s" % selected.name)

	# Ataque se tiver arma
	if selected.weapons_data.size() > 0:
		var weapon_scene = selected.weapons_data[randi() % selected.weapons_data.size()]
		var weapon_node = weapon_scene.instantiate()
		var mult_soldier = get_precision_factor(selected.rating)
		var mult_weapon  = get_precision_factor(weapon_node.rating)
		var damage = int((mult_soldier + mult_weapon) * weapon_node.damage)
		var target = choose_front_target(grid)
		if target:
			var roll = randi() % 6 + 1
			var threshold = selected.rating + 1
			if roll <= threshold:
				target.apply_damage(damage)
				print("%s → %s com %s: dano %d (roll %d<=%d). HP:%d" % [
					selected.name, target.name, weapon_node.weapon_name,
					damage, roll, threshold, target.hp])
			else:
				print("%s errou %s com %s (roll %d>%d)" % [
					selected.name, target.name, weapon_node.weapon_name, roll, threshold])
	else:
		print("%s sem arma para atacar" % selected.name)

	await get_tree().create_timer(0.5).timeout
	end_turn()

# Alterna turno e verifica fim de combate
func end_turn() -> void:
	if current_turn == Turn.PLAYER:
		current_turn = Turn.ENEMY
	else:
		current_turn = Turn.PLAYER
	if check_end_condition():
		return
	start_turn()

# Verifica vitória/derrota
func check_end_condition() -> bool:
	if not any_alive(player_grid):
		print("🚩 Jogador derrotado!")
		return true
	if not any_alive(enemy_grid):
		print("🏆 Inimigos derrotados!")
		return true
	return false

# Verifica se há unidade viva no grid
func any_alive(grid: Node2D) -> bool:
	for u in grid.get_children():
		if (u is UnitSoldierClass or u is UnitMechaClass) and u.is_alive():
			return true
	return false

# Seleciona alvo na linha de frente usando configurações do UnitGrid
func choose_front_target(attacker_grid: Node2D) -> Node2D:
	# Converte para UnitGrid para ler columns/rows
	var grid_node = attacker_grid as UnitGrid
	var columns = grid_node.columns
	var rows = grid_node.rows
	# Define defensores como filhos do grid oposto
	var defenders := []
	if attacker_grid == player_grid:
		defenders = enemy_grid.get_children()
	else:
		defenders = player_grid.get_children()
	
	# Linha de frente: primeira coluna (coluna 0) em cada linha
	var front := []
	for row in range(rows):
		var idx = row * columns
		if idx < defenders.size() and defenders[idx].is_alive():
			front.append(defenders[idx])
	# Fallback: qualquer vivo
	if front.size() == 0:
		for dv in defenders:
			if dv.is_alive():
				front.append(dv)
	if front.size() == 0:
		return null
	return front[randi() % front.size()]

# Fator de precisão por rating
func get_precision_factor(r: int) -> float:
	match r:
		UnitSoldierClass.Rating.E: return 0.25
		UnitSoldierClass.Rating.D: return 0.4
		UnitSoldierClass.Rating.C: return 0.6
		UnitSoldierClass.Rating.B: return 0.78
		UnitSoldierClass.Rating.A: return 0.9
		UnitSoldierClass.Rating.S: return 1.1
	return 1.0
