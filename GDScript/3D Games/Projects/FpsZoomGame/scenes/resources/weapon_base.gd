extends Resource ## Este Resource define os dados básicos de todas as armas do jogo.
class_name Weapon_Base

@export var weapon_name        : String  = ""
@export var activate_anim      : String  = ""
@export var shoot_anim         : String  = ""
@export var reload_anim        : String  = ""
@export var deactivate_anim    : String  = ""
@export var out_of_ammo_anim   : String  = ""

@export var damage             : int     = 1
@export var current_ammo       : int     = 0
@export var reserve_ammo       : int     = 0
@export var magazine_size      : int     = 0
@export var max_ammo           : int     = 0

@export var auto_fire          : bool    = false

@export var fire_rate : float = 0.1
@export var reload_time : float = 1.5
@export var recoil_strength : float = 2.0

@export var bullet_scene : PackedScene
@export var shoot_sound : AudioStream
