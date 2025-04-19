extends Node2D

@export var speed : int = 75

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var shoot_timer: Timer = $shoot_timer
@onready var player_area: Area2D = $Area2D
@onready var damage_taken_cd: Timer = $damage_taken_cd

@onready var shoot_origin: Marker2D = $shoot_origin
@onready var bullet = load("res://Scenes/bullet.tscn")
@onready var game = get_tree().get_root().get_node("Game")

signal got_exp
signal health_change

var health = 500
var max_health = 500
var can_shoot = true
var facing : int = 1
var level : int = 1
var exp_per_level = 8
var cur_exp = 0
var can_take_damage = true
var velocity

func _physics_process(delta: float) -> void:
	velocity = Vector2(0, 0)
	if Input.is_action_pressed("Left"):
		velocity.x = -speed * delta
		facing = -1
	elif Input.is_action_pressed("Right"):
		velocity.x = speed * delta
		facing = 1
		animation.flip_h = true
		
	if Input.is_action_pressed("Up"):
		velocity.y = -speed * delta
	elif Input.is_action_pressed("Down"):
		velocity.y = speed * delta
		
	velocity = velocity.normalized() * speed * delta
		
	animation.flip_h = (facing == 1)
	shoot_origin.position.x = - facing * abs(shoot_origin.position.x)
			
	if can_shoot:
		var new_bullet = bullet.instantiate()
		new_bullet.speed = 280
		new_bullet.initial_position = shoot_origin.position + position
		new_bullet.damage = 7 + level * 2
		new_bullet.dir = (get_global_mouse_position() - shoot_origin.position - position).normalized()
		get_parent().add_child.call_deferred(new_bullet)
		
		can_shoot = false
		shoot_timer.start()
		
	position += velocity
	check_damage()


func check_damage():
	if not player_area.get_overlapping_areas().is_empty() and can_take_damage:
		health -= player_area.get_overlapping_areas().size() * 10
		if health <= 0:
			get_tree().reload_current_scene()
		
		health_change.emit(health)
		can_take_damage = false
		damage_taken_cd.start()


func _on_shoot_timer_timeout() -> void:
	can_shoot = true


func _on_damage_taken_cd_timeout() -> void:
	can_take_damage = true
	
func on_mob_death():
	cur_exp += 1
	if cur_exp >= exp_per_level:
		cur_exp = 0
		level += 1
		shoot_timer.wait_time = max(shoot_timer.wait_time * 0.9, 0.2)
		exp_per_level += 5
		health = min(health + 100, max_health)
	
	health_change.emit(health)
	got_exp.emit()
