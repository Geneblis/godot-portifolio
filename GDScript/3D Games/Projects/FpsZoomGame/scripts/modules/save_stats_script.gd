extends Node
class_name SaveSystem
@export var hand: Node3D

const SAVE_PATH := "user://weapons_save.ini"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("save"):
		_save_weapons_to_file()
	elif event.is_action_pressed("load"):
		_load_weapons_from_file()
#	end

#region Salvamento e Carregamento com ConfigFile
func _save_weapons_to_file() -> void:
	var cfg := ConfigFile.new() # É tipo um container temporario para salvar oq ira salvar no arquivo.
	cfg.load(SAVE_PATH) #Le o arquivo q ja existe

	var inventory_status := []
	for weapon in hand.get_children():
		var ds = weapon.get("dup_state")
		if ds != null:
			inventory_status.append({
				"weapon_name":  ds.weapon_name,
				"current_ammo": ds.current_ammo,
				"reserve_ammo": ds.reserve_ammo
			})

	# Só altera a seção e a chave que você quer, Grava o Array<Dictionary> na seção "weapons", chave "inventory_status"
	cfg.set_value("weapons", "inventory_status", inventory_status)

	# Grava tudo de volta, incluindo seções que você não tocou
	var err = cfg.save(SAVE_PATH)
	if err != OK:
		push_error("❌ Não foi possível salvar em %s" % SAVE_PATH)
	else:
		print("✅ Weapons saved:", inventory_status)


func _load_weapons_from_file() -> void:
	var cfg := ConfigFile.new()
	var err = cfg.load(SAVE_PATH)
	if err != OK:
		print("⚠️ Nenhum arquivo de save encontrado em", SAVE_PATH)
		return

	# Recupera o Array<Dictionary> salvo ou usa lista vazia
	var inventory_status = cfg.get_value("weapons", "inventory_status", [])
	if typeof(inventory_status) != TYPE_ARRAY:
		push_error("Formato inválido: esperava um Array de Dictionary em 'inventory_status'")
		return

	# Aplica cada entrada de volta aos dup_state das armas na cena
	for entry in inventory_status:
		var item = entry.get("weapon_name", "")
		for weapon in hand.get_children():
			var ds = weapon.get("dup_state")
			if ds != null and ds.weapon_name == item:
				ds.current_ammo = entry.get("current_ammo", ds.current_ammo)
				ds.reserve_ammo = entry.get("reserve_ammo", ds.reserve_ammo)
	print("✅ Weapons loaded!")
#endregion
