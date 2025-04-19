extends ProgressBar

@onready var player: Node2D = $"../.."
@onready var exp_text: Label = $exp_text

func _ready() -> void:
	value = 0
	max_value = player.exp_per_level
	value = player.cur_exp
	exp_text.text = str(player.level)
	player.got_exp.connect(on_exp_change)
	
func on_exp_change():
	max_value = player.exp_per_level
	value = player.cur_exp
	exp_text.text = str(player.level)
