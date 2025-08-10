# GameHandler.gd
extends Node2D
class_name GameHandler

# Paths para os grids (configurar no Inspector)
@export var player_grid_path: NodePath
@export var enemy_grid_path:  NodePath

var player_grid: UnitGrid
var enemy_grid:  UnitGrid

enum Turn { PLAYER, ENEMY }
var current_turn: Turn

func begin_game() -> void:
	randomize()
	player_grid = get_node(player_grid_path)
	enemy_grid  = get_node(enemy_grid_path)
	# garante que as posições estejam organizadas
	player_grid.populate()
	enemy_grid.populate()
	_decide_first_turn()

func _decide_first_turn() -> void:
	current_turn = Turn.PLAYER if randi()%2 == 1 else Turn.ENEMY
	_start_turn()

func _start_turn() -> void:
	if current_turn == Turn.PLAYER:
		print("=== Turno do Jogador ===")
		_perform_turn(player_grid, enemy_grid)
	else:
		print("=== Turno do Inimigo ===")
		_perform_turn(enemy_grid, player_grid)

func _perform_turn(attacker: UnitGrid, defender: UnitGrid) -> void:
	# 1) Filter vivos do atacante
	var shooters := []
	for u in attacker.get_children():
		if u.is_alive():
			shooters.append(u)
	if shooters.size() <= 0:
		print("Nenhuma unidade viva para atirar. Pulando turno.")
		_end_turn()
		return

	# 2) Escolhe um atirador aleatório
	var shooter = shooters[randi() % shooters.size()]
	print("Atirador:", shooter.name)

	# 3) Filter vivos do defensor
	var targets := []
	for u in defender.get_children():
		if u.is_alive():
			targets.append(u)
	if targets.size() <= 0:
		print("Nenhum alvo vivo. Pulando turno.")
		_end_turn()
		return

	# 4) Escolhe alvo aleatório
	var target = targets[randi() % targets.size()]

	# 5) Se o atirador tiver armas, dispara uma aleatória
	if shooter.weapons_data.size() > 0:
		var weapon_scene = shooter.weapons_data[randi() % shooter.weapons_data.size()]
		var weapon = weapon_scene.instantiate()  # Arma
		var dmg = int((get_precision_factor(shooter.rating)
					 + get_precision_factor(weapon.rating))
					 * weapon.damage)
		var roll = randi() % 6 + 1
		var threshold = shooter.rating + 1
		if roll <= threshold:
			target.apply_damage(dmg)
			print("%s -> %s com %s: -%d HP (roll %d≤%d). Restam %d" %
				[shooter.name, target.name, weapon.weapon_name, dmg, roll, threshold, target.hp])
		else:
			print("%s errou %s (roll %d>%d)" % [shooter.name, target.name, roll, threshold])
	else:
		print("%s está desarmado!" % shooter.name)

	# 6) Delay visual e troca de turno
	await get_tree().create_timer(0.5).timeout
	_end_turn()

func _end_turn() -> void:
	current_turn = Turn.ENEMY if current_turn == Turn.PLAYER else Turn.PLAYER
	if _check_end(): return
	_start_turn()

func _check_end() -> bool:
	if not _any_alive(player_grid):
		print("🚩 Jogador derrotado!")
		return true
	if not _any_alive(enemy_grid):
		print("🏆 Inimigos derrotados!")
		return true
	return false

func _any_alive(grid: UnitGrid) -> bool:
	for u in grid.get_children():
		if u.is_alive():
			return true
	return false

func get_precision_factor(r: int) -> float:
	match r:
		UnitSoldierClass.Rating.E: return 0.25
		UnitSoldierClass.Rating.D: return 0.4
		UnitSoldierClass.Rating.C: return 0.6
		UnitSoldierClass.Rating.B: return 0.78
		UnitSoldierClass.Rating.A: return 0.9
		UnitSoldierClass.Rating.S: return 1.1
	return 1.0
