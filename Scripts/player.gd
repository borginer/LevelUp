extends Node2D
class_name Player

@onready var weapons: Marker2D = $Weapons
@onready var lumi: Lumi = $Weapons/Lumi
@onready var shoot_origin: Marker2D = $Weapons/BulletGun/shoot_origin
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_area: Area2D = $Area2D

@onready var damage_taken_cd: Timer = $damage_taken_cd
@onready var blink_cd: Timer = $blink_cd

@onready var game = get_tree().get_root().get_node("GameManager/Level1")

signal leveled_up
signal upgrade_player(upgrade_type: Globals.PlayerUpgradeTypes)
signal got_exp
signal health_change

var can_blink: bool = true
var can_take_damage: bool = true

var health: float = 500
var max_health: float = 500
var level: int = 1
var exp_per_level: int = 8
var cur_exp: int = 0
var level_heal: int = 100

var speed : int = 115
var blink_dist: int = 100
var facing: int = 1

var velocity: Vector2

func _ready() -> void:
	upgrade_player.connect(_on_player_upgrade)

func _physics_process(delta: float) -> void:	
	handle_input()
	movement_and_animation(delta)
	handle_collisions()

func handle_input():
	velocity = Vector2(0, 0)
	if Input.is_action_pressed("Left"):
		velocity.x = -speed
		facing = -1
		shoot_origin.position.x = - facing * abs(shoot_origin.position.x)
	elif Input.is_action_pressed("Right"):
		velocity.x = speed
		facing = 1
		shoot_origin.position.x = - facing * abs(shoot_origin.position.x)
		
	if Input.is_action_pressed("Up"):
		velocity.y = -speed
	elif Input.is_action_pressed("Down"):
		velocity.y = speed
		
	if Input.is_action_pressed("Blink") and can_blink:
		position += blink_dist * velocity.normalized()
		can_blink = false
		blink_cd.start()

func movement_and_animation(delta: float):
	animation.set_flip_h.call_deferred(facing == 1)
	velocity = velocity.normalized() * speed
	position += velocity * delta
	
func handle_collisions() -> void:
	if not player_area.get_overlapping_areas().is_empty() and can_take_damage:
		health -= player_area.get_overlapping_areas().size() * 10
		if health <= 0:
			get_tree().reload_current_scene()
		
		health_change.emit(health)
		can_take_damage = false
		damage_taken_cd.start()

func _on_damage_taken_cd_timeout() -> void:
	can_take_damage = true
	
func _on_blink_cd_timeout() -> void:
	can_blink = true	
	
func on_mob_death():
	cur_exp += 1
	if cur_exp >= exp_per_level:
		level_up()
	
	health_change.emit(health)
	got_exp.emit()

func level_up():
	cur_exp = 0
	level += 1
	exp_per_level += 3
	heal_player(level_heal)
	leveled_up.emit()
	
func heal_player(amount: float):
	health = min(health + amount, max_health)
	
func _on_player_upgrade(upgrade_type: Globals.PlayerUpgradeTypes):
	match upgrade_type:
		Globals.PlayerUpgradeTypes.WEAP_CD:
			for weap: Weapon in weapons.get_children():
				weap.set_weapon_speed(max(0.25, weap.weapon_speed_mult * 0.92))
				weap.update()
		Globals.PlayerUpgradeTypes.BASE_DAMAGE:
			for weap: Weapon in weapons.get_children():
				weap.set_base_damage(weap.base_damage + 2)
				weap.update()
		Globals.PlayerUpgradeTypes.BULLET_DAMAGE:
			for weap: Weapon in weapons.get_children():
				if weap is BulletGun:
					weap.set_damage_mult(weap.damage_mult + 0.2)
					weap.update()
		Globals.PlayerUpgradeTypes.LAZER_DAMAGE:
			for weap: Weapon in weapons.get_children():
				if weap is Lumi:
					weap.set_damage_mult(weap.damage_mult + 0.2)
					weap.update()
		Globals.PlayerUpgradeTypes.BULLET_TARGETS:
			for weap: Weapon in weapons.get_children():
				if weap is BulletGun:
					weap.bullet_targets += 1
		Globals.PlayerUpgradeTypes.LAZER_TARGETS:
			for weap: Weapon in weapons.get_children():
				if weap is Lumi:
					weap.lazer_targets += 1
