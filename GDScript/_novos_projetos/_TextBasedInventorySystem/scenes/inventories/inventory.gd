# Inventory.gd
extends Node
class_name Inventory

@export var inventory_holder: String = "Nobody"
@export var capacity_kg: float = 200.0
var items: Array = []

signal item_added(item)
signal item_removed(item)

func _ready():
	# se não houver nada em items, popula com os filhos
	if items.size() <= 0:
		for child in get_children():
			# você pode filtrar só nós que herdam de ItemData ou tenham peso
			if child.has_method("get_weight"):
				items.append(child)
				emit_signal("item_added", child)

func get_total_weight() -> float:
	var sum = 0.0
	for it in items:
		sum += it.weight
	return sum

func can_add(item) -> bool:
	return get_total_weight() + item.weight <= capacity_kg

func add_item(item) -> bool:
	if can_add(item):
		items.append(item)
		emit_signal("item_added", item)
		return true
	return false

func remove_item(item) -> bool:
	if item in items:
		items.erase(item)
		emit_signal("item_removed", item)
		return true
	return false
