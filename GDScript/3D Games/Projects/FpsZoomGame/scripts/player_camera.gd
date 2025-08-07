extends Camera3D
##Esse sistema tem a unica responsabilidade para recoil visual.

var max_recoil_degrees: float =  40.0
var _base_rotation: Vector3 = Vector3.ZERO
var _current_recoil: float = 0.0           # recoil acumulado
var _current_rotation: float               # rotação da cabeça

@export var recoil_speed: float       =   6.0    # quanto ganha de recoil por segundo
@export var head_node: Node3D

func _process(delta: float) -> void:
	if Input.is_action_pressed("shoot") and _current_recoil <= max_recoil_degrees:
		## Configuração do recoil e rotação atual 
		_current_recoil = min(_current_recoil + recoil_speed * delta, max_recoil_degrees)
		_current_rotation = head_node.rotation_degrees.x
		head_node.rotation_degrees.x = min(_current_rotation + _current_recoil * delta, max_recoil_degrees)
	else: ##reseting
		_current_recoil = 0.0
