extends Node2D
class_name Player

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var shoot_origin: Marker2D = $shoot_origin
@onready var player_area: Area2D = $Area2D

@onready var damage_taken_cd: Timer = $damage_taken_cd
@onready var lumi_cd: Timer = $lumi_cd
@onready var blink_cd: Timer = $blink_cd
@onready var bullet_cd: Timer = $bullet_cd
@onready var lumi_delay_cd: Timer = $lumi_delay_cd

@onready var bullet = load("res://Scenes/bullet.tscn")
@onready var lazer = load("res://Scenes/lazer.tscn")
@onready var game = get_tree().get_root().get_node("GameManager/Level1")

signal leveled_up
signal upgrade_player(upgrade_type: Globals.PlayerUpgradeTypes)
signal got_exp
signal health_change
signal lumi_sig

var can_shoot: bool = true
var can_lumi: bool = true
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

var base_lumi_cd: float = 2
var base_bullet_cd: float = 1

var base_damage: float = 10
var all_weapon_speed_mult: float = 1
var lazer_damage_mod: float = 1
var bullet_damage_mod: float = 1
var lazer_targets: int = 2
var bullet_targets: int = 1

var velocity: Vector2

func _ready() -> void:
	lumi_sig.connect(_on_lumi_signal)
	upgrade_player.connect(_on_player_upgrade)
	update_bullet_stats()
	update_lazer_stats()

func _physics_process(delta: float) -> void:	
	handle_input()
	movement_and_animation(delta)
	handle_shooting()
	handle_lumi()
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

func distance(p1: Vector2, p2: Vector2) -> float:
	return (p1 - p2).abs().length()
	
func sort_closest(e1: Mob, e2: Mob):
	return distance(position, e1.position) < distance(position, e2.position)
	
func in_range(e1: Mob):
	return distance(position, e1.position) < 280
	
func is_alive(e1: Mob):
	return not e1.is_dead
	
func create_lazer(from: Vector2, to: Vector2):
	var new_lazer :Node2D = lazer.instantiate()
	new_lazer.position = to
	new_lazer.x_len = distance(from, to)
	new_lazer.rotation = (from - to).angle()
	get_parent().add_child(new_lazer)
	
func handle_lumi():
	if not can_lumi:
		return
	lumi_sig.emit()
	
# returns the next point to shoot a lazer from
func hit_enemy(e: Mob, from: Vector2) -> Vector2:
	if not e or e.is_dead:
		return from
	e.deal_damage(base_damage * lazer_damage_mod)
	create_lazer(from, e.position)
	return e.position
	

func _on_lumi_signal():
	var enemies = get_tree().get_nodes_in_group("enemies")\
		.filter(in_range).filter(is_alive)
	
	var last_e_pos: Vector2 = position
	if enemies.size() > 0:
		can_lumi = false
		lumi_cd.start()
		last_e_pos = hit_enemy(enemies[0], last_e_pos)
		enemies.remove_at(0)
		enemies.shuffle()
		lumi_delay_cd.start()
		await lumi_delay_cd.timeout
	else:
		return
	
	for i in range(0, min(enemies.size(), lazer_targets), 1):
		if not enemies[i]:
			continue
		var cur_e: Mob = enemies[i]
		last_e_pos = hit_enemy(cur_e, last_e_pos)
		lumi_delay_cd.start()
		await lumi_delay_cd.timeout

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

func handle_shooting() -> void:
	if not can_shoot:
		return 
		
	var enemies = get_tree().get_nodes_in_group("enemies").filter(is_alive).filter(in_range)
	enemies.sort_custom(sort_closest)
	
	if enemies.size() > 0:
		create_bullet(enemies[0].position)
	else:
		return
		
	can_shoot = false
	bullet_cd.start()
		
func create_bullet(to: Vector2):
	var bullet_speed = 280
	var from = position + shoot_origin.position
	var damage = base_damage * bullet_damage_mod		
	var dir = (to - from).normalized()
	var new_bullet: Bullet = bullet.instantiate()
	var hits_left = bullet_targets
	
	new_bullet.create_bullet(bullet_speed, dir, damage, from, hits_left)
	get_parent().add_child.call_deferred(new_bullet)
		
func _on_shoot_timer_timeout() -> void:
	can_shoot = true

func _on_damage_taken_cd_timeout() -> void:
	can_take_damage = true
	
func _on_lumi_cd_timeout() -> void:
	can_lumi = true
	
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
			all_weapon_speed_mult = max(0.25, all_weapon_speed_mult * 0.92)
			update_lazer_stats()
			update_bullet_stats()
		Globals.PlayerUpgradeTypes.BASE_DAMAGE:
			base_damage += 2
		Globals.PlayerUpgradeTypes.BULLET_DAMAGE:
			bullet_damage_mod += 0.2
			update_bullet_stats()
		Globals.PlayerUpgradeTypes.LAZER_DAMAGE:
			lazer_damage_mod += 0.2
			update_lazer_stats()
		Globals.PlayerUpgradeTypes.BULLET_TARGETS:
			bullet_targets += 1
		Globals.PlayerUpgradeTypes.LAZER_TARGETS:
			lazer_targets += 1

func update_lazer_stats():
	lumi_cd.wait_time = base_lumi_cd * all_weapon_speed_mult

func update_bullet_stats():
	bullet_cd.wait_time = base_bullet_cd * all_weapon_speed_mult
