extends Node2D

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused == false:
			get_tree().paused = true
		else:
			get_tree().paused = false
