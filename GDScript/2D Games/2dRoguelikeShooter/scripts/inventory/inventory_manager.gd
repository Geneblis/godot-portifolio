extends Control
@onready var items_container: VBoxContainer = $PanelContainer/VBoxContainer

# Exemplo de “base de dados” de itens
var items = [
	{"name":"Espada", "desc":"Dano: 10\nDurabilidade: 100"},
	{"name":"Água",  "desc":"Restaura 20 HP"},
	{"name":"Chave", "desc":"Abre portas trancadas"}
]

func _ready() -> void:
	_populate()

func _populate() -> void:
	for child in items_container.get_children():
		items_container.remove_child(child)
		child.queue_free()
	for item in items:
		var b = Button.new()
		b.text = item.name
		b.tooltip_text = item.desc
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		items_container.add_child(b)

func add_item(name: String, desc: String) -> void:
	items.append({"name":name,"desc":desc})
	_populate()

func remove_item(name: String) -> void:
	# remove primeira ocorrência
	for i in range(items.size()):
		if items[i].name == name:
			items.remove_at(i)
			break
	_populate()
