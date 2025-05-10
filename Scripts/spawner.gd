extends Node2D

@onready var spawn_point: Marker2D = $spawn_point
@onready var mob = load("res://Scenes/mob.tscn")
@onready var player = get_tree().get_root().get_node("GameManager/Level1/Player")

var radius = 460

func _on_spawn_timer_timeout() -> void:
	if get_tree().get_nodes_in_group("enemies").size() > 5 + player.level * 2.5:
		return
	var amount = randi_range(1 + player.level, 3 + player.level * 1.2)
	for i in range(amount):
		var angle = randf_range(0, 2)
		var new_mob: Mob = mob.instantiate()
		new_mob.mob_death.connect(player.on_mob_death)
		var distance = radius * randf_range(0.8, 1.2)
		new_mob.position = player.position + Vector2.UP.rotated(angle * PI) * distance
		get_parent().add_child(new_mob)
		
