extends Node2D

@onready var color_rect: ColorRect = $ColorRect
@onready var fadeout: Timer = $fadeout

var x_len = 100
var fading = false
var lazer_width: float = 6

func _ready() -> void:
	color_rect.set_size(Vector2(x_len, lazer_width))
	color_rect.set_position(Vector2(0, -lazer_width / 2))
	color_rect.pivot_offset = Vector2(0, lazer_width / 2)
	
func _process(_delta: float) -> void:
	if fading:
		color_rect.color.a = fadeout.time_left / fadeout.wait_time

func _on_time_to_live_timeout() -> void:
	fading = true
	fadeout.start()

func _on_fadeout_timeout() -> void:
	queue_free()
