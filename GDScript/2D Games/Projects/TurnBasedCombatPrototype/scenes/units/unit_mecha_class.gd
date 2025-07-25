# Soldado.gd
#----------------------------------------------
# Define um "Soldado" como um AnimatedSprite2D que carrega
# dados básicos: nome, vida, rating e inventário de armas.
#----------------------------------------------
extends Node2D
class_name UnitMechaClass

# ENUM para classificação de performance
enum Rating { E, D, C, B, A, S }
enum Type {Soldier, Mobile}

# Propriedades exportadas no Inspector
@export var nome: String = ""
@export var max_hp: int = 100
@export var rating: Rating = Rating.C
@export var unit_type: Type = Type.Soldier
@export var sprite: Sprite2D
@export var animated_sprite: AnimatedSprite2D

# Inventário de armas: Array de Dictionary
# Cada Dictionary deve conter:
# {
#   "weapon_type": String,   # "small", "medium" ou "large"
#   "weapon_name": String,   # ex: "Pistola", "Rifle"
#   "damage": int            # valor de dano base
# }
@export var weapons_data: Array = []

# Estado dinâmico
var hp: int

func _ready():
	check_weapons_list()
	# Inicializa a vida corrente
	hp = max_hp

func is_alive() -> bool:
	return hp > 0

func check_weapons_list() -> void:
	print("--- Inventário de armas de %s ---" % nome)
	for packed_scene in weapons_data:
		
		# Instancia a cena da arma
		if packed_scene == null:
			print("section has no weapon value, ignoring...")
		else:
			var arma_node = packed_scene.instantiate()
			var w_name = arma_node.weapon_name
			var w_type = arma_node.weapon_type
			var w_dmg = arma_node.damage
			print("%s | Tipo: %s | Dano: %d" % [w_name, w_type, w_dmg])
	print("------------------------------")

func get_weapons_by_type(weapon_type: String) -> Array:
	var list := []
	for w in weapons_data:
		if w.get("weapon_type", "") == weapon_type:
			list.append(w)
	return list

# Exemplo de método para aplicar dano ao Soldado
func apply_damage(amount: int) -> void:
	hp = max(hp - amount, 0)
	if hp == 0:
		_on_death()

func _on_death() -> void:
	# Pode emitir sinal ou notificar o CombatManager
	emit_signal("soldado_morto", self)

# Sinal para morte
signal soldado_morto(soldier)
