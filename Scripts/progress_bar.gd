extends ProgressBar

@onready var mob = $".."

var max_health : float
var initial_color : Color = get_theme_stylebox("fill").color

func _ready() -> void:
	mob.health_change.connect(on_health_change)
	min_value = 0
	max_health = mob.health
	max_value = max_health
	value = max_health
	
func on_health_change(health: float):
	value = health
	update_health_color()
	
func update_health_color():
	var r : float = (max_health - value)/max_health 
	var g : float = value/max_health
	var b = 0.0
	var style = get_theme_stylebox("fill").duplicate() as StyleBoxLine
	style.color = Color(r, initial_color.g * g, b, 1)
	add_theme_stylebox_override("fill", style)
