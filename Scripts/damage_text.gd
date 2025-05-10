extends Control

@onready var damage: Label = $damage

var speed = 30
var value

func _ready() -> void:
	damage.text = str(int(value))
	position.x += 5 * randf_range(-1, 1)


func _process(delta: float) -> void:
	position.y -= speed * delta
	position.x += 0.2 * speed * delta
	if speed > 10:
		speed -= delta * 50
	

func _on_lifetime_timeout() -> void:
	queue_free()
