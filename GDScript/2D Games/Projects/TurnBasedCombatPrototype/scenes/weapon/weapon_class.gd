# Arma.gd
#----------------------------------------------
# Define uma arma genérica como Node2D contendo um Sprite2D
# e propriedades exportadas para nome, tipo e dano.
#----------------------------------------------
extends Node2D
class_name WeaponClass

# ENUM para tipos de arma
enum WeaponType { SMALL, MEDIUM, LARGE }

# Propriedades exportadas
@export var weapon_name: String = ""
@export var weapon_type: WeaponType = WeaponType.SMALL
@export var damage: int = 10

# Referência ao nó Sprite2D interno
@onready var icon: Sprite2D = $Sprite2D

func _ready():
	# Aqui você pode inicializar ou ajustar o sprite, se necessário
	pass

# Retorna uma descrição amigável da arma
func get_description() -> String:
	var type_str: String = ""
	if weapon_type == WeaponType.SMALL:
		type_str = "Small"
	elif weapon_type == WeaponType.MEDIUM:
		type_str = "Medium"
	elif weapon_type == WeaponType.LARGE:
		type_str = "Large"
	else:
		type_str = "Unknown"
	return "%s (%s) - Damage: %d" % [weapon_name, type_str, damage]
