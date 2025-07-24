# UnitGrid.gd
#----------------------------------------------
# Um container 4x2 para posicionar até 8 unidades (Node2D)
# Pode ser usado para time do jogador (esquerda) e inimigo (direita).
#----------------------------------------------
extends Node2D
class_name UnitGrid

# Quantidade de colunas e linhas
@export var columns: int = 2
@export var rows: int = 4

# Espaçamento entre cells (em pixels)
@export var cell_size: Vector2 = Vector2(64, 64)

# Margem interna (offset do canto superior esquerdo)
@export var margin: Vector2 = Vector2(0, 0)

# Lista de unidades (instâncias prontas de Node2D)
var units: Array[Node2D] = []

# Limpa o grid e posiciona as unidades passadas
func populate(units_list: Array[Node2D]) -> void:
	# Remove filhos antigos
	for child in get_children():
		remove_child(child)
		child.queue_free()

	units = []

	# Adiciona e posiciona até columns * rows unidades
	var total = min(units_list.size(), columns * rows)
	for i in range(total):
		var unit = units_list[i]
		add_child(unit)
		units.append(unit)
		# Cálculo de coluna e linha
		var col = i % columns
		var row = i / columns
		# Define posição relativa a este Node2D
		unit.position = margin + Vector2(col * cell_size.x, row * cell_size.y)

# Opcional: debug visual do grid no editor
#func _draw():
#	draw_style_box(get_stylebox("panel", "WindowDialog"), Rect2(margin, cell_size * Vector2(columns, rows)))
