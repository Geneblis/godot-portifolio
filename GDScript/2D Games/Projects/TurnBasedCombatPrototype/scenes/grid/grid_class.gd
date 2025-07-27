# UnitGrid.gd
#----------------------------------------------
# Um container MxN para posicionar unidades (Node2D)
# Pode ser usado para time do jogador (esquerda) e inimigo (direita).
#----------------------------------------------
extends Node2D
class_name UnitGrid

# Quantidade de colunas e linhas
@export var columns: int = 2
@export var rows:    int = 4

# Espaçamento entre células (em pixels)
@export var cell_size: Vector2 = Vector2(64, 64)

# Margem interna (offset do canto superior esquerdo)
@export var margin: Vector2 = Vector2(0, 0)

# Lista de unidades (instâncias prontas de Node2D)
var units: Array[Node2D] = []

func populate() -> void:
	# Coleta filhos existentes como unidades
	units = []
	for u in get_children():
		if u is Node2D:
			units.append(u)
	# Limita ao máximo de cells
	var max_cells = columns * rows
	if units.size() > max_cells:
		units = units.slice(0, max_cells)
	# Posiciona em row-major
	for i in range(units.size()):
		var unit = units[i]
		var col = i % columns
		var row = i / columns
		unit.position = margin + Vector2(col * cell_size.x, row * cell_size.y)
	# Reordena a árvore de cena para refletir units[]
	_reorder_children()

# Reordena os filhos na árvore de acordo com units[]
func _reorder_children() -> void:
	for unit in units:
		remove_child(unit)
	for unit in units:
		add_child(unit)

# Retorna lista de todas as unidades (row-major order)
func get_units() -> Array[Node2D]:
	return units.duplicate()

# Retorna apenas unidades vivas
func get_alive_units() -> Array[Node2D]:
	var alive := []
	for u in units:
		if u.has_method("is_alive") and u.is_alive():
			alive.append(u)
	return alive
	
func clear_grid():
	# Remove filhos antigos
	for child in get_children():
		remove_child(child)
		child.queue_free()
