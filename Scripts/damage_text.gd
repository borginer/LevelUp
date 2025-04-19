extends Control

@onready var damage: Label = $damage

var speed = 45
var value

func _ready() -> void:
	damage.text = str(int(value))


func _process(delta: float) -> void:
	position.y -= speed * delta
	if speed > 10:
		speed -= delta * 50
	

func _on_lifetime_timeout() -> void:
	queue_free()
