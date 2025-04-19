extends Node2D

@onready var animations: AnimatedSprite2D = $AnimatedSprite2D
@onready var bullet_timeout: Timer = $bullet_timeout
@onready var reverse_timer: Timer = $reverse_timer

var speed : int
var dir : Vector2
var initial_position: Vector2
var reverse = false
var damage

func _ready() -> void:
	position = initial_position
	animations.play("default")
	scale = Vector2(0.4, 0.4)
	
func _physics_process(delta: float) -> void:
	position += speed * delta * dir 
	if scale.x < 3:
		scale += 3 * scale * delta
		
	if (position - initial_position).length() > 300:
		queue_free()

func _on_bullet_timeout_timeout() -> void:
	queue_free()


func _on_reverse_timer_timeout() -> void:
	reverse = true
