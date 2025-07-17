extends Control

const SAVE_PATH := "res://json_data/data.json"

@onready var list_container : VBoxContainer = $ListContainer
@onready var item_input      : LineEdit      = $HBoxContainer/ItemInput
@onready var btn_add         : Button        = $HBoxContainer/Add
@onready var btn_remove      : Button        = $HBoxContainer/Remove
@onready var btn_clear       : Button        = $HBoxContainer/Clear

var items : Array[String] = []

func _ready() -> void: # -- Começo, declarações de evento, etc.
	btn_add.pressed.connect(_on_add_pressed)
	btn_remove.pressed.connect(_on_remove_pressed)
	btn_clear.pressed.connect(_on_clear_pressed)
	_load_items() #carrega oq ja tem no json

#region -- Funcionalidade visual, nenhuma manipulação JSON.
func _refresh_list() -> void:
	## Limpa a VBox antes de recriar os labels
	for child in list_container.get_children():
		list_container.remove_child(child)
		child.queue_free()

	## Adiciona os itens atuais como labels, pega o texto para o texto q esta dentro do item.
	for text in items:
		var lbl = Label.new()
		lbl.text = "• %s" % text
		list_container.add_child(lbl)

	## Salva no JSON
	_save_items()
#end

# funcionalidade para botoes
func _on_add_pressed() -> void:
	var text = item_input.text.strip_edges()
	if text != "":
		items.append(text)
		item_input.text = ""
		_refresh_list()

func _on_remove_pressed() -> void:
	if items.size() > 0:
		items.pop_back()
		_refresh_list()

func _on_clear_pressed() -> void:
	## Limpa o array da memória
	items.clear()
	
	## Limpa a UI (VBox)
	for child in list_container.get_children():
		list_container.remove_child(child)
		child.queue_free()
	## Atualiza e salva
	_save_items()
	print("📦 Cleared all items.")
#endregion

#region -- Funcionalidades praticas, manipulação JSON.
## salva os items
func _save_items() -> void:
	var data = {"items": items}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()
		print("💾 Saved %d items." % items.size())
	else:
		push_error("Failed to open %s for writing." % SAVE_PATH)

## carrega os items
func _load_items() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ) # ja retorna null caso file seja invalido.
	if not FileAccess.file_exists(SAVE_PATH) or not file:
		push_error("Failed to open %s for reading." % SAVE_PATH)
		return
	
	var conteudo = file.get_as_text() # pega conteudo do json cru
	file.close()

	## cria um novo arquivo q vai pegar o texto bruto, transformar em algo q o Godot saiba ler.
	var parsed = JSON.new()
	if parsed.parse(conteudo) != OK: # Converte string JSON → Dictionary/Array
		push_warning("Invalid JSON format in %s" % SAVE_PATH)
		return
	var save_data = parsed.data.get("items", [])

	items = []
	for i in save_data:
		items.append(str(i)) # força conversão para String
	_refresh_list()
	#end
#endregion
