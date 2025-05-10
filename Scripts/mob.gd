extends Node2D
class_name Mob

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $ProgressBar
@onready var player = get_tree().get_root().get_node("GameManager/Level1/Player")
@onready var damage_text = load("res://Scenes/damage_text.tscn")
@onready var damage_position: Marker2D = $damage_position
@onready var death_timer: Timer = $death_timer
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var area_2d: Area2D = $Area2D
@onready var personal_space: Area2D = $PersonalSpace

const bullet_type = preload("res://Scripts/bullet.gd")

signal health_change
signal mob_death

var speed : int = 70
var anti_claster_speed = 12
var health : float = 50
var is_dead = false
var gravity_power : int = 10
var dir : Vector2 = Vector2(1, 0)
var velocity

func _ready() -> void:
	animation.scale.x = -dir.x
	var mob_type : int = randi_range(0, 2)
	scale = Vector2(0.8, 0.8)
	match mob_type:
		0: animation.play("dragon") 
		1: animation.play("moose")
		2: 
			animation.play("tauron")
			scale = Vector2(1.4, 1.4)
			health = 100
			
	health_bar.set_max_value(health)
	health_change.emit(health)
	
func _process(delta: float) -> void:
	if is_dead: return
	velocity = Vector2(0, 0)
	
	if not in_camera_range(position - player.position):
		queue_free()
		
	if dir.x > 0:
		animation.flip_h = false
	else:
		animation.flip_h = true
	
	dir = (player.position - position).normalized()
	velocity += dir * speed * delta
	
	for area in personal_space.get_overlapping_areas():
		var area_owner = area.get_parent()
		if area_owner is Mob:
			anti_claster_move(area_owner.position, delta)
	
	position += velocity

func in_camera_range(vect: Vector2):
	var camera_view = get_viewport_rect().size / 2.685
	return abs(vect.x) < camera_view.x / 1.6 and\
		   abs(vect.y) < camera_view.y / 1.6

func anti_claster_move(from: Vector2, delta: float):
	var move_dir = position - from
	velocity += move_dir.normalized() * anti_claster_speed * delta

func _on_area_2d_area_entered(area: Area2D) -> void:
	var object = area.get_parent()
	if object is Bullet:
		handle_hit(object)
	
func handle_hit(bullet : bullet_type) -> void:
	var damage : float = bullet.damage * randf_range(0.8, 1.1)
	deal_damage(damage)
	

func deal_damage(damage : float):
	health -= damage
	health_change.emit(health)
	create_floating_damage(damage)
	if not is_dead and health <= 0:
		initiate_death()
	
func initiate_death() -> void:
	is_dead = true
	collision_shape_2d.call_deferred("set_disabled", true)
	area_2d.call_deferred("set_monitoring", false)
	animation.rotation -= 20 * sign((player.position - position).x)
	speed = 0
	mob_death.emit()
	death_timer.start()
	await get_tree().create_timer(1, false).timeout
	animation.set_visible(false)
	position = Vector2(100000, 100000)

func create_floating_damage(damage : float) -> void:
	var new_damage_text = damage_text.instantiate()
	new_damage_text.position = position + damage_position.position
	new_damage_text.value = damage
	get_parent().add_child(new_damage_text)
	
func _on_death_timer_timeout() -> void:
	call_deferred("queue_free")
	
