extends Node2D

@onready var spawn_point: Marker2D = $spawn_point
@onready var mob = load("res://Scenes/mob.tscn")
@onready var player = get_tree().get_root().get_node("Game/Player")

var radius = 550

func _on_spawn_timer_timeout() -> void:
	var amount = randi_range(1 + player.level, 3 + player.level)
	for i in range(amount):
		var angle = randf_range(0, 2)
		var new_mob = mob.instantiate()
		new_mob.mob_death.connect(player.on_mob_death)
		var distance = radius * randf_range(0.8, 1.2)
		new_mob.position = player.position + Vector2.UP.rotated(angle * PI) * distance
		get_parent().add_child(new_mob)
