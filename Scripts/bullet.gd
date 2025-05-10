extends Node2D
class_name Bullet

@onready var animations: AnimatedSprite2D = $AnimatedSprite2D
@onready var bullet_timeout: Timer = $bullet_timeout
@onready var reverse_timer: Timer = $reverse_timer

var reverse = false

var speed : int
var dir : Vector2
var initial_position: Vector2
var damage
var hits_left = 1

func create_bullet(_speed: int, _dir: Vector2, 
		_damage: float, _initial_position: Vector2, _hits_left: int) -> void:
	speed = _speed
	dir = _dir
	damage = _damage
	initial_position = _initial_position
	position = initial_position
	hits_left = _hits_left
	
func _ready() -> void:
	animations.play("default")
	
func _physics_process(delta: float) -> void:
	position += speed * delta * dir 
		
	if (position - initial_position).length() > 300:
		queue_free()

func _on_bullet_timeout_timeout() -> void:
	queue_free()


func _on_reverse_timer_timeout() -> void:
	reverse = true


func _on_area_2d_area_entered(_area: Area2D) -> void:
	hits_left -= 1
	if hits_left == 0:
		queue_free()
