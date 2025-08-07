extends Control
class_name InventoryUI

@export var inventory_path: NodePath
var inv: Inventory

@onready var list       : VBoxContainer = $MarginContainer/List
@onready var info_label : Label         = $InfoLabel
@onready var status_label: Label = $StatusLabel

func _ready() -> void:
	inv = get_node(inventory_path)
	inv.item_added.connect(_on_item_added)
	inv.item_removed.connect(_on_item_removed)
	info_label.z_index   = 100
	info_label.visible   = false
	_refresh_list()
	_set_status_info()

func _set_status_info() -> void:
	status_label.text = "%s's Inventory \n%skg - Maximum Capacity" % [inv.inventory_holder,inv.capacity_kg]

func _on_item_added(item: ItemData) -> void:
	_add_slot(item)

func _on_item_removed(_item: ItemData) -> void:
	_refresh_list()

func _refresh_list() -> void:
	for child in list.get_children():
		list.remove_child(child)
		child.queue_free()
	for item in inv.items:
		_add_slot(item)

func _add_slot(item: ItemData) -> void:
	var slot = HBoxContainer.new()
	slot.name = item.item_name
	slot.set_meta("item", item)

	# Texto com nome e peso
	var lbl = Label.new()
	lbl.text = "%s – %.1f kg" % [item.item_name, item.weight]
	slot.add_child(lbl)

	slot.mouse_filter = Control.MOUSE_FILTER_PASS

#region Hover: mostra descrição e stats
	slot.mouse_entered.connect(func() -> void:
		var it = slot.get_meta("item") as ItemData
		info_label.text = "%s\n\n%s\n\n%s" % [it.item_name, it.description, it.stats]
		info_label.visible = true
	)

	slot.mouse_exited.connect(func() -> void:
		info_label.visible = false
	)

	list.add_child(slot)
#endregion
