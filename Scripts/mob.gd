extends Node2D

@export var speed : int = 28
@export var health : float = 50

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $ProgressBar
@onready var player = get_tree().get_root().get_node("Game/Player")
@onready var damage_text = load("res://Scenes/damage_text.tscn")
@onready var damage_position: Marker2D = $damage_position

signal health_change
signal mob_death

var gravity_power : int = 10
var dir : Vector2 = Vector2(1, 0)

func _ready() -> void:
	speed += randi_range(-3, 3)
	animation.scale.x = -dir.x
	var mob_type : int = randi_range(0, 2)
	match mob_type:
		0: animation.play("dragon") 
		1: animation.play("moose")
		2: animation.play("tauron")

func _physics_process(delta: float) -> void:
	dir = (player.position - position).normalized()
	position += dir * speed * delta
	if dir.x > 0:
		animation.flip_h = false
	else:
		animation.flip_h = true
	

func _on_area_2d_area_entered(area: Area2D) -> void:
	var damage : float = area.get_parent().damage * randf_range(0.8, 1)
	health -= damage
	var new_damage_text = damage_text.instantiate()
	new_damage_text.position = position + damage_position.position
	new_damage_text.value = damage
	get_parent().add_child(new_damage_text)
	
	health_change.emit(health)
	if health <= 0:
		mob_death.emit()
		queue_free()
