extends Resource ## Este Resource define os dados básicos de todas as armas do jogo.
class_name Weapon_Base

@export_category("Base Definitions")
@export var weapon_name        : String  = ""

@export_category("Configuration")
@export var damage             : int     = 1
@export var current_ammo       : int     = magazine_size
@export var reserve_ammo       : int     = 0
@export var magazine_size      : int     = 0
@export var max_ammo           : int     = 0

@export var auto_fire: bool = false
@export var raycast: bool = false
@export var fire_rate : float = 0.1
@export var reload_time : float = 1.5
@export var recoil_strength : float = 2.0

@export_category("Specialties")
@export var weapon_nose: NodePath        #must be an node3d
@export var raycast_node: NodePath       #must be an raycast
@export var animation_player: NodePath   #must be an animationplayer
@export var muzzle: NodePath             #must be an image


@export var bullet_scene : PackedScene
@export var shoot_sounds: AudioStreamRandomizer
@export var sound_player: NodePath               #must be an AudioStreamPlayer3D
