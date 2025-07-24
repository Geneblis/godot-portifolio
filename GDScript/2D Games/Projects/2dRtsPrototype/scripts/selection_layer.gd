# SelectionLayer.gd
extends Control

@export var units_container_path : NodePath = "../Units"
@export var grid_spacing         : float   = 40.0  # espaço entre unidades na formação

var drag_start : Vector2
var drag_end   : Vector2
var dragging   : bool    = false
var selected   : Array   = []

func _ready() -> void:
	# Permite que este Control receba eventos de mouse mesmo passando sobre nós filhos
	mouse_filter = Control.MOUSE_FILTER_PASS

func update():
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# Botão esquerdo pressionado: inicia arraste de seleção
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			drag_start = get_local_mouse_position()
			drag_end   = drag_start
			dragging   = true
			_clear_selection()
			update()  # desenhar o retângulo inicial

		# Botão esquerdo solto: finaliza arraste e seleciona unidades
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and dragging:
			dragging = false
			_select_units_in_rect()
			update()  # limpar o retângulo

		# Botão direito pressionado: ordena movimento das unidades selecionadas
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_order_move_to(get_global_mouse_position())

	elif event is InputEventMouseMotion and dragging:
		drag_end = get_local_mouse_position()
		update()

func _draw() -> void:
	if dragging:
		var rect = Rect2(drag_start, drag_end - drag_start).abs()
		draw_rect(rect, Color(0, 0.5, 1, 0.2))
		draw_rect(rect, Color(0, 0.5, 1), false, 2)

func _clear_selection() -> void:
	for unit in selected:
		if is_instance_valid(unit):
			unit.select(false)
	selected.clear()

func _select_units_in_rect() -> void:
	var rect = Rect2(drag_start, drag_end - drag_start).abs()
	var units_container = get_node(units_container_path)
	for unit in units_container.get_children():
		var u = unit as Node2D
		if rect.has_point(u.global_position):
			selected.append(u)
			u.select(true)

func _order_move_to(click_pos: Vector2) -> void:
	if selected.size() == 0:
		return

	var count = selected.size()
	var cols  = int(ceil(sqrt(count)))
	var rows  = int(ceil(count / cols))
	var half_w = (cols - 1) / 2.0
	var half_h = (rows - 1) / 2.0

	for i in range(count):
		var col = i % cols
		var row = i / cols
		var offset = Vector2(
			(col - half_w) * grid_spacing,
			(row - half_h) * grid_spacing
		)
		var dest = click_pos + offset
		var unit = selected[i] as Node2D

		# Se a unidade tiver um NavigationAgent2D, define target no agent
		if unit.has_node("NavigationAgent2D"):
			var agent = unit.get_node("NavigationAgent2D") as NavigationAgent2D
			agent.target_position = dest
		else:
			# Se não tiver NavigationAgent2D, ajusta diretamente a propriedade target_position
			if unit.has_method("set_target_position"):
				unit.call("set_target_position", dest)
			elif unit.has("target_position"):
				unit.target_position = dest
