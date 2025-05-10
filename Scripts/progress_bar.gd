extends ProgressBar

@onready var mob = $".."

var initial_color : Color = get_theme_stylebox("fill").color

func _ready() -> void:
	mob.health_change.connect(_on_health_change)
	min_value = 0
	max_value = mob.health
	value = max_value
	
func _on_health_change(health: float):
	value = health
	if value <= 0:
		queue_free()
	call_deferred("update_health_color")
	
func set_max_value(val: float):
	max_value = val
	
func update_health_color():
	var r : float = (max_value - value)/max_value * 0.4
	var g : float = value/max_value
	var b = 0.0
	var style = get_theme_stylebox("fill").duplicate() as StyleBoxLine
	style.color = Color(initial_color.r + r, initial_color.g * g, b, 1)
	add_theme_stylebox_override("fill", style)
